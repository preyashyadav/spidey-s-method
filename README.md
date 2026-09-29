# spidey-kit

Personal Claude Code setup: global rules, a plugin with the story pipeline, and two shell commands.

## Install (once per machine)

```bash
git clone <your-remote>/spidey-kit ~/code/spidey-kit
~/code/spidey-kit/install.sh
```

What it does:
- Symlinks `global/CLAUDE.md` to `~/.claude/CLAUDE.md` (existing file is backed up) and `global/rules/*.md` into `~/.claude/rules/`
- Adds this repo as a local plugin marketplace and installs `spidey@spidey-kit`
- Adds the BMAD marketplace and installs `bmad-method@bmad`
- Links `claude-new` and `spidey-wt` into `~/.local/bin`

Edit files in this repo; the symlinks and the local marketplace pick up changes. Restart Claude Code sessions after changing hooks or skills.

## What loads where

| Layer | Where | Loads |
|---|---|---|
| Global rules | `~/.claude/CLAUDE.md`, `~/.claude/rules/` | Every session, every repo |
| Plugin hooks | `plugins/spidey/hooks` | Every session; each hook is inert unless the repo opts in (`scripts/check`, `scripts/fmt`, `.claude/protected-paths`) |
| Plugin skills | `/spidey:kickoff`, `/spidey:spec`, `/spidey:story` | Only when you invoke them |
| Plugin agents | `spidey:test-writer`, `spidey:story-reviewer`, `spidey:qa-evaluator` | Only when delegated to |
| Project | `CLAUDE.md`, `.claude/settings.json`, `docs/stories/` | Written by `/spidey:kickoff` |
| Auto memory | `~/.claude/projects/<repo>/memory/` | Per repo, written by Claude |

## Flow

**New repo**
```bash
claude-new my-app "metrics dashboard for Postgres clusters"
```
Creates the directory, inits git, launches Claude with `/spidey:kickoff`, which writes `CLAUDE.md`, `scripts/check`, `scripts/fmt`, `.claude/settings.json`, `.claude/protected-paths`, and `docs/stories/`. In an existing repo, run `claude` then `/spidey:kickoff`.

**Plan**
- New product: BMAD (`bmad-help` shows the next step). Stop at stories; put them in `docs/stories/`.
- Feature: `/spidey:spec <idea>` interviews you and writes stories with dependencies marked.
- One-line change: just ask Claude.

Commit the stories before building.

**Build**, one terminal per story:
```bash
spidey-wt docs/stories/002-ingest-api.md
spidey-wt docs/stories/003-dashboard.md
```
Each gets its own worktree and branch pinned to the current commit, then runs `/spidey:story`:
test-writer writes failing tests → implement → `scripts/check` → story-reviewer (fresh context) → fixes → qa-evaluator if `ui: true` → commit on the story branch.

Only parallelize stories that don't depend on each other. If a repo needs setup in a fresh worktree (installing deps, copying `.env`), add an executable `scripts/setup-worktree`.

**Review and merge**, from the main checkout:
- Merge the story branch, run `/code-review` on the result, open the PR.
- `spidey-wt clean 002-ingest-api` removes the worktree.
- Optional interactive review session: `claude --agent spidey:story-reviewer` inside the worktree.

## Hooks

| Hook | Trigger | Behavior |
|---|---|---|
| `gate.sh` | Stop | If the tree has changes and `scripts/check` exists, runs it; blocks the turn on failure and feeds the last 80 lines back. Caches passes per tree state. `SPIDEY_GATE=off` disables it for a session |
| `guard.sh` | Before Write/Edit | Blocks edits to paths matching `.claude/protected-paths` |
| `fmt.sh` | After Write/Edit | Runs `scripts/fmt <file>` if present |

## Customizing

- Add a rule you had to repeat twice to the project `CLAUDE.md`, or to `global/` if it applies everywhere.
- Plugin agents can't set `hooks`, `mcpServers`, or `permissionMode`. For an agent that needs those, copy it to `.claude/agents/` in the project.
- Validate after edits: `claude plugin validate .`
