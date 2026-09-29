#!/usr/bin/env bash
set -u
root="${CLAUDE_PROJECT_DIR:-$PWD}"
list="$root/.claude/protected-paths"
[ -f "$list" ] || exit 0
SPIDEY_HOOK_INPUT=$(cat) python3 - "$root" "$list" <<'PY'
import sys, json, os, fnmatch
root, listfile = sys.argv[1], sys.argv[2]
try:
    data = json.loads(os.environ.get("SPIDEY_HOOK_INPUT", ""))
except Exception:
    sys.exit(0)
ti = data.get("tool_input") or {}
path = ti.get("file_path") or ti.get("notebook_path")
if not path:
    sys.exit(0)
rel = os.path.relpath(os.path.abspath(os.path.join(root, path)), os.path.abspath(root))
patterns = [l.strip() for l in open(listfile) if l.strip() and not l.lstrip().startswith("#")]
for p in patterns:
    if fnmatch.fnmatch(rel, p) or fnmatch.fnmatch(os.path.basename(rel), p):
        sys.stderr.write(f"Blocked: {rel} matches protected pattern '{p}' in .claude/protected-paths. Ask the user before changing it.\n")
        sys.exit(2)
sys.exit(0)
PY
