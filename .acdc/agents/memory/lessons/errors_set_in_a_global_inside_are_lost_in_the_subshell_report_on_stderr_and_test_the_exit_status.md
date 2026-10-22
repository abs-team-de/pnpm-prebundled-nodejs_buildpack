---
name: 'Errors set in a global inside $(...) are lost in the subshell; report on stderr and test the exit status'
description: 'Errors set in a global inside $(...) are lost in the subshell; report on stderr and test the exit status'
type: lesson
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources:
  - bin/supply:29-35
  - lib/utils.sh:53-56
  - test/supply.bats
---

## Compiled Truth

What happens: A function called as `V=$(fn)` runs in a subshell, so a global it sets (bin/supply's former RESOLVE_ERROR) never reaches the caller. An unsupported range like ">=18 <21" then tried to download node-v-linux-x64.tar.gz instead of showing its error.
How we found out: While reworking resolve_node_version for v1.4.0; reproduced with a failing test in test/supply.bats before fixing. The existing tests used `run fn` and checked only the status, so the lost message had gone unnoticed.
What to do: Write the error to stderr inside the function and return non-zero; the caller uses `if ! V=$(fn); then exit 1; fi`. Tests for error paths assert on the output, and at least one test drives the real caller (bin/supply), not only the function.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->

---

## Timeline

- 2026-10-22 | Created: Errors set in a global inside $(...) are lost in the subshell; report on stderr and test the exit status
