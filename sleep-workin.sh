#!/usr/bin/env bash
# Simulate an idle service and clean up after termination signals.
set -eu

STATE_DIR="${1:-${XDG_STATE_HOME:-$HOME/.local/state}/bash-sleep-server}"
PID_FILE="$STATE_DIR/service.pid"
child_pid=''
umask 077
mkdir -p -- "$STATE_DIR"

exec 8>"$STATE_DIR/service.lock"
if ! flock -n 8; then
    echo "Another service instance is already running." >&2
    exit 1
fi

cleanup() {
    trap - EXIT HUP INT TERM
    if [[ -n "$child_pid" ]]; then
        kill "$child_pid" 2>/dev/null || true
        wait "$child_pid" 2>/dev/null || true
    fi
    rm -f -- "$PID_FILE"
}
trap cleanup EXIT
trap 'exit 0' HUP INT TERM
printf '%s\n' "$$" > "$PID_FILE"

while true; do
    # Waiting uses negligible CPU and allows Bash to handle signals promptly.
    sleep 60 8>&- &
    child_pid=$!
    wait "$child_pid"
    child_pid=''
done
