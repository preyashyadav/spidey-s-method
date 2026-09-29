#!/usr/bin/env bash
set -euo pipefail
kit="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="$HOME/.claude"
bin_dir="${SPIDEY_BIN_DIR:-$HOME/.local/bin}"
stamp=$(date +%Y%m%d%H%M%S)

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak-$stamp"
    echo "backed up $dst -> $dst.bak-$stamp"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst"
}

link "$kit/global/CLAUDE.md" "$claude_dir/CLAUDE.md"
for f in "$kit"/global/rules/*.md; do
  link "$f" "$claude_dir/rules/spidey-$(basename "$f")"
done

chmod +x "$kit"/bin/* "$kit"/plugins/spidey/scripts/*.sh
for f in "$kit"/bin/*; do
  link "$f" "$bin_dir/$(basename "$f")"
done

repo=""
if url=$(git -C "$kit" remote get-url origin 2>/dev/null); then
  repo=$(printf '%s' "$url" | sed -E 's#^(git@github.com:|https://github.com/)##; s#\.git$##')
fi
printf 'SPIDEY_KIT_REPO=%s\n' "$repo" > "$claude_dir/spidey-kit.env"

claude plugin validate "$kit"
claude plugin marketplace add "$kit" || true
claude plugin install spidey@spidey-kit || true
claude plugin marketplace add bmad-code-org/bmad-plugins || true
claude plugin install bmad-method@bmad || true

case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "add $bin_dir to your PATH to use claude-new and spidey-wt" ;;
esac
echo "done. Restart any open Claude Code sessions."
