#!/bin/bash
# Install the graphics snap under test plus the dummy consumer, and connect them.
# Usage: tests/setup.sh path/to/gaming-graphics-core26_*.snap
set -euo pipefail
[ -f "${1:-}" ] || { echo "usage: $0 path/to/gaming-graphics-core26_*.snap" >&2; exit 1; }
snap list core26 >/dev/null 2>&1 || sudo snap install core26
sudo snap install --dangerous "$1"
cd "$(dirname "$0")"

chmod 755 consumer/bin/*
mkdir -p consumer/graphics 
snap pack consumer /tmp
sudo snap install --dangerous /tmp/gaming-graphics-tester_0.1_*.snap

# --dangerous installs don't auto-connect.
sudo snap connect gaming-graphics-tester:gaming-graphics-core26 gaming-graphics-core26:gaming-graphics-core26
for plug in opengl x11 home; do
  sudo snap connect "gaming-graphics-tester:$plug"
done
