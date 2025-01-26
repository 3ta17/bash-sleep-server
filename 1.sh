#!/bin/bash

# Startup script for sleep-walking-server
# Ensure /tmp/sleep-walking-server exists and has executable permissions

PID_FILE="/tmp/sleep-walking-server.pid"

case "$1" in
  start)
    if [ -f "$PID_FILE" ]; then
      echo "Error: sleep-walking-server is already running (PID: $(cat $PID_FILE))."
      exit 1
    fi
    echo "Starting sleep-walking-server..."
    /tmp/sleep-walking-server & echo $! > "$PID_FILE"
    echo "Server started with PID: $(cat $PID_FILE)"
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      echo "Stopping sleep-walking-server..."
      kill $(cat "$PID_FILE") && rm -f "$PID_FILE"
      echo "Server stopped."
    else
      echo "Error: No PID file found. Is the server running?"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 start|stop"
    exit 1
    ;;
esac
