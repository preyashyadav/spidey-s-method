---
name: spec
description: Turn a feature idea into one or more story files in docs/stories/ by interviewing the user. Use for features that fit in a few stories; use BMAD planning for a new product.
disable-model-invocation: true
argument-hint: "<feature idea>"
---
Feature idea: $ARGUMENTS

1. Decide the size. If this is a new product, a new service, or needs a PRD and architecture decisions across many components, tell the user to run BMAD planning (`bmad-help` shows the next step) and write its stories into `docs/stories/`, then stop. If it is one small change describable in a sentence, tell the user to just ask for it directly, then stop.
2. Use subagents to read the relevant parts of the codebase so your questions are grounded. Do not load large files into this context.
3. Interview the user with AskUserQuestion. Ask about the hard parts: behavior at the edges, failure modes, data ownership, auth, what is explicitly out of scope, and how to prove it works end to end. Skip anything the code already answers. At most three rounds.
4. Split the feature into vertical stories, each shippable and testable alone. If stories share an interface (API shape, schema, event format), put that contract in the first story so parallel stories build against a fixed definition.
5. Write each story to `docs/stories/NNN-slug.md` using `docs/stories/_template.md`. Number after the highest existing story.
6. Mark in each story whether it depends on another story, so the user knows which can run in parallel.

End with the list of story files, their dependencies, and which ones can start in parallel.
