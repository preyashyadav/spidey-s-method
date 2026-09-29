# <Project name>

<One line: what this is and who it is for.>

## Commands
- Check (types, lint, unit tests): `scripts/check`
- Format one file: `scripts/fmt <path>`
- Dev server: `<command>` on port `<port>`
- Single test: `<command pattern>`
- E2E: `<command>`

## Architecture
<Filled after planning. Link docs/architecture.md; list only rules a reviewer should enforce, e.g. "business logic lives in services/, never in route handlers".>

## Conventions
<Only what differs from the stack's defaults.>

## Gotchas
<Env vars, local services, flaky areas, anything that has bitten a session before.>

## Workflow
- Work comes from story files in docs/stories/. Run `/spidey:story <file>` to implement one.
- A task is done when `scripts/check` passes and every acceptance criterion has a test.
- When compacting, keep the story path, base ref, modified files, and failing test names.
