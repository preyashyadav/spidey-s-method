---
name: kickoff
description: Scaffold the spidey workflow into the current repository (CLAUDE.md, scripts/check, scripts/fmt, settings, protected paths, docs/stories). Run once per new repo.
disable-model-invocation: true
argument-hint: "[one-line description of the project]"
---
Set up this repository for the spidey workflow. Project description from the user: $ARGUMENTS

Templates live in `${CLAUDE_PLUGIN_ROOT}/templates/`. Read them before writing anything.

1. Inspect the repo: languages, package manager, test runner, linter, formatter, type checker, framework, dev server command. If the repo is empty, ask the user for the stack in one AskUserQuestion call (language, framework, test runner) and stop until answered.
2. If `git rev-parse` fails, run `git init` and make an initial empty commit so the gate hook has a base.
3. Write `scripts/check`: one executable script that runs, in order and failing fast, type check, lint, and unit tests for this stack. It must be fast enough to run after every turn (target under 60s); keep slow E2E out of it. Use `set -euo pipefail`. Run it once and fix it until it passes on the current tree.
4. Write `scripts/fmt`: executable, takes one file path, formats only that file with the repo's formatter, and exits 0 when the file type has no formatter.
5. Write `CLAUDE.md` from `templates/CLAUDE.md`. Fill in real commands and only facts Claude cannot derive from the code. Keep it under 80 lines. Leave the Architecture section as the placeholder if the architecture is not decided yet.
6. Copy `templates/settings.json` to `.claude/settings.json`, merging with any existing file rather than overwriting. If `~/.claude/spidey-kit.env` exists and sets `SPIDEY_KIT_REPO` to an `owner/repo`, add an `extraKnownMarketplaces.spidey-kit` entry with `{"source": {"source": "github", "repo": "<value>"}}` so a fresh clone on another machine can install the plugin.
7. Copy `templates/protected-paths` to `.claude/protected-paths` and add stack-specific entries (migration directories, generated code, lockfiles).
8. Create `docs/stories/` with `templates/story.md` copied to `docs/stories/_template.md`.
9. Append `.qa/`, `CLAUDE.local.md` and `.claude/settings.local.json` to `.gitignore`.
10. Commit the scaffold on the current branch with message `chore: spidey kickoff`.

Finish with three lines: what `scripts/check` runs and how long it took, anything you could not configure, and the next step (`/spidey:spec` for a feature, or BMAD planning for a new product).
