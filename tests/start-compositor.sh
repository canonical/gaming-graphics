#!/bin/bash
# Start a headless Weston compositor with Xwayland, so tests can use both
# Wayland and X11.
# Usage: tests/start-compositor.sh path/to/weston.log
set -euo pipefail
log=${1:?usage: $0 path/to/weston.log}
socket=wayland-0

export XDG_RUNTIME_DIR="/run/user/$(id -u)"
sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chown "$(id -u):$(id -g)" "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

nohup weston --backend=headless --renderer=pixman --xwayland \
  --socket="$socket" --idle-time=0 >"$log" 2>&1 &

# Wait for the Wayland socket, and for Weston to report which X display
# it picked (it takes the first free one).
display=
for _ in $(seq 1 50); do
  display=$(sed -n 's/.*xserver listening on display \(:[0-9]*\).*/\1/p' "$log" | head -n 1)
  [ -S "$XDG_RUNTIME_DIR/$socket" ] && [ -n "$display" ] && break
  sleep 0.2
done
if [ ! -S "$XDG_RUNTIME_DIR/$socket" ] || [ -z "$display" ]; then
  echo "weston failed to start" >&2
  cat "$log" >&2
  exit 1
fi

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR" >>"$GITHUB_ENV"
  echo "WAYLAND_DISPLAY=$socket" >>"$GITHUB_ENV"
  echo "DISPLAY=$display" >>"$GITHUB_ENV"
fi
