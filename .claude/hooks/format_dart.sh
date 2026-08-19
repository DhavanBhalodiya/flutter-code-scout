#!/usr/bin/env bash
# format_dart.sh - Claude Code PostToolUse hook.
# Reads the hook payload JSON from stdin, extracts tool_input.file_path, and runs
# `dart format` on it when (and only when) it is a .dart file. Fast, single-file.
#
# Design: always exit 0 so a formatting hiccup never blocks an edit. If neither jq
# nor python3 is available, or no usable path is found, it silently no-ops.

set -u

# Slurp the hook payload from stdin (may be empty).
payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# Extract the edited file path. Prefer jq; fall back to python3; else give up.
file_path=""
if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
elif command -v python3 >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | python3 -c \
    'import sys,json;
try:
    d=json.load(sys.stdin)
    print((d.get("tool_input") or {}).get("file_path") or "")
except Exception:
    print("")' 2>/dev/null)"
fi

# Only format existing .dart files.
case "$file_path" in
  *.dart)
    if [ -f "$file_path" ] && command -v dart >/dev/null 2>&1; then
      dart format "$file_path" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
