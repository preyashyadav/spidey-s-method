#!/usr/bin/env bash
set -u
input=$(cat)
[ "${SPIDEY_GATE:-on}" = "off" ] && exit 0
root="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$root" 2>/dev/null || exit 0
[ -x scripts/check ] || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -n "$(git status --porcelain)" ] || exit 0

state="${CLAUDE_PLUGIN_DATA:-$HOME/.cache/spidey}/gate"
mkdir -p "$state"
hashcmd="shasum"; command -v shasum >/dev/null 2>&1 || hashcmd="sha1sum"
key=$(printf '%s' "$root" | $hashcmd | cut -c1-16)
tree=$(python3 - <<'PY'
import hashlib, subprocess
h = hashlib.sha1()
h.update(subprocess.run(["git", "diff", "HEAD"], capture_output=True).stdout)
files = subprocess.run(["git", "ls-files", "--others", "--exclude-standard", "-z"], capture_output=True).stdout.split(b"\0")
for f in sorted(x for x in files if x):
    h.update(f)
    try:
        h.update(open(f, "rb").read())
    except OSError:
        pass
print(h.hexdigest())
PY
)

[ "$(cat "$state/$key.pass" 2>/dev/null)" = "$tree" ] && exit 0

active=$(printf '%s' "$input" | python3 -c 'import sys,json
try: print(str(json.load(sys.stdin).get("stop_hook_active", False)).lower())
except Exception: print("false")')
if [ "$active" = "true" ] && [ "$(cat "$state/$key.fail" 2>/dev/null)" = "$tree" ]; then
  exit 0
fi

out=$(./scripts/check 2>&1)
code=$?
if [ $code -eq 0 ]; then
  printf '%s' "$tree" > "$state/$key.pass"
  rm -f "$state/$key.fail"
  exit 0
fi
printf '%s' "$tree" > "$state/$key.fail"
{
  echo "scripts/check failed (exit $code). Fix the root cause before finishing; do not weaken or skip tests. If this is a pre-existing failure unrelated to your change, say so explicitly and stop."
  echo "--- last 80 lines ---"
  printf '%s\n' "$out" | tail -n 80
} >&2
exit 2
