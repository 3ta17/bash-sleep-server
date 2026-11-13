#!/usr/bin/env bash
# Manage the simulated service stored beside this script.
set -eu

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SERVICE="$SCRIPT_DIR/sleep-workin.sh"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/bash-sleep-server"
PID_FILE="$STATE_DIR/service.pid"

case "${1:-}" in
    start|stop) ;;
    *) echo "Usage: $0 start|stop" >&2; exit 2 ;;
esac

umask 077
mkdir -p -- "$STATE_DIR"
# Serialize commands. The background service must not inherit this lock.
exec 9>"$STATE_DIR/control.lock"
flock -x 9

is_running() {
    [[ -f "$PID_FILE" ]] || return 1
    read -r pid < "$PID_FILE" || return 1
    [[ "$pid" =~ ^[1-9][0-9]*$ ]] || return 1
    kill -0 "$pid" 2>/dev/null || return 1
    # Reject stale PID files pointing to unrelated processes.
    grep -Fxzq -- "$SERVICE" "/proc/$pid/cmdline" 2>/dev/null
}

case "$1" in
    start)
        if is_running; then
            echo "Service is already running (PID: $pid)." >&2
            exit 1
        fi
        # The service lock protects against a live service with a missing PID file.
        if ! flock -n "$STATE_DIR/service.lock" true; then
            echo "Service lock is held; check the existing service before retrying." >&2
            exit 1
        fi
        rm -f -- "$PID_FILE"
        nohup bash "$SERVICE" "$STATE_DIR" </dev/null >>"$STATE_DIR/service.log" 2>&1 9>&- &
        service_pid=$!
        for ((attempt = 0; attempt < 30; attempt++)); do
            if is_running && [[ "$pid" == "$service_pid" ]]; then
                echo "Service started (PID: $pid)."
                exit 0
            fi
            sleep 0.1
        done
        echo "Startup could not be confirmed. Check $STATE_DIR/service.log." >&2
        exit 1
        ;;
    stop)
        if ! is_running; then
            if ! flock -n "$STATE_DIR/service.lock" true; then
                echo "Service lock is held but its PID cannot be verified; investigate manually." >&2
                exit 1
            fi
            rm -f -- "$PID_FILE"
            echo "Service is not running."
            exit 0
        fi
        service_pid=$pid
        kill -TERM "$service_pid"
        for ((attempt = 0; attempt < 50; attempt++)); do
            if ! is_running && flock -n "$STATE_DIR/service.lock" true; then
                echo "Service stopped."
                exit 0
            fi
            sleep 0.1
        done
        echo "Stop could not be confirmed; inspect PID $service_pid before retrying." >&2
        exit 1
        ;;
esac
