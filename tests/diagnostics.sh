#!/bin/bash
# Print diagnostics useful for debugging a failed test run.
# Usage: tests/diagnostics.sh [path/to/weston.log]

section() { echo; echo "== $*"; }

section "snap list";        snap list
section "snap connections"; snap connections gaming-graphics-tester
section "snap changes";     snap changes
if [ -n "${1:-}" ]; then
  section "weston log";     cat "$1"
fi
section "AppArmor/seccomp denials"
sudo dmesg | grep -Ei 'apparmor="DENIED"|seccomp' | tail -n 200
section "snapd journal";    sudo journalctl -u snapd --no-pager -n 200
section "environment";      env | sort
exit 0
