#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="/etc/goxray"

start_goxray() {
    /usr/bin/goxray $(cat "$CONFIG_DIR/default.xray") &
    GOXRAY_PID=$!
}

stop_goxray() {
    if [[ -n "${GOXRAY_PID:-}" ]] && kill -0 "$GOXRAY_PID" 2>/dev/null; then
        kill "$GOXRAY_PID"
        wait "$GOXRAY_PID" 2>/dev/null || true
    fi
}

trap 'stop_goxray; exit' SIGTERM SIGINT

echo "Starting goxray..."
start_goxray

wait "$GOXRAY_PID"
exit

# TODO: fix automated restart on configuration update
# if ! command -v inotifywait &>/dev/null; then
#     echo "Warning: inotify-tools not installed, config changes will not trigger restart"
#     wait "$GOXRAY_PID"
#     exit
# fi
#
# while inotifywait -e close_write,moved_to,create "$CONFIG_DIR" 2>/dev/null; do
#     echo "Config changed, restarting goxray..."
#     stop_goxray
#     start_goxray
# done
