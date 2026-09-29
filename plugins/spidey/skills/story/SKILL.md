---
name: story
description: Implement one story file end to end with tests first, the check gate, an independent review, and browser QA for UI stories.
disable-model-invocation: true
argument-hint: "<path to docs/stories/NNN-slug.md>"
---
Story: $ARGUMENTS

Record the base ref now with `git rev-parse HEAD`; the reviewer needs it.

1. Read the story, CLAUDE.md, and docs/architecture.md if present. If the story has no testable acceptance criteria or contradicts the architecture, stop and tell the user what is missing.
2. If you are on the default branch, create `story/<NNN-slug>` from the current HEAD.
3. Tests first: delegate to the `spidey:test-writer` subagent with the story path. Check that its tests fail for the expected reason.
4. Implement the smallest change that makes those tests pass and satisfies every acceptance criterion. Stay inside the story's scope; list anything else you notice as a follow-up instead of doing it.
5. Run `scripts/check` and fix failures at the root cause. Never skip, delete, or loosen a test to get green. The Stop hook enforces this gate too.
6. Delegate to the `spidey:story-reviewer` subagent with the story path and the base ref. Fix every P0 and P1 finding, rerun `scripts/check`, and send the reviewer back once if you changed behavior. Do not act on findings outside correctness, security, or the story's requirements.
7. If the story frontmatter has `ui: true`, delegate to the `spidey:qa-evaluator` subagent. Fix failures and rerun it once.
8. Update the story's `status` to `done` and commit on the story branch with a conventional commit message. Do not push or open a PR unless the user asks.

Final report, evidence rather than claims:
- `scripts/check` result (last lines of output)
- Each acceptance criterion and the test that proves it
- Reviewer verdict and what you fixed
- QA verdict and screenshot paths, if run
- Follow-ups you noticed but did not do
