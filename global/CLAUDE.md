# Global rules (all projects)

## How I work
- Direct, concise, technically precise. No inflated claims; say what was verified and how.
- Show evidence for "done": the command you ran and its output, not a summary of success.
- No code comments unless I ask for them.
- Stay inside the task's scope. List unrelated issues as follow-ups instead of fixing them.
- Prefer the smallest diff that solves the problem. No new dependencies without asking.

## Engineering defaults
- Fix root causes. Never skip, delete, or loosen a test to make it pass.
- Validate at trust boundaries; fail loudly with typed or explicit errors, never swallow them.
- External calls get timeouts. Secrets never go in code, logs, or test fixtures.
- Read the existing pattern for a thing before adding a new one; follow it.

## When unsure
- Ambiguous requirement or architectural choice: ask before building.
- Two failed attempts at the same fix: stop, explain what you learned, propose a different approach.
