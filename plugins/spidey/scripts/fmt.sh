#!/usr/bin/env bash
set -u
root="${CLAUDE_PROJECT_DIR:-$PWD}"
fmt="$root/scripts/fmt"
[ -x "$fmt" ] || exit 0
file=$(python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("file_path",""))
except Exception:
    print("")')
[ -n "$file" ] && [ -f "$file" ] || exit 0
cd "$root" && "$fmt" "$file" >/dev/null 2>&1
exit 0
