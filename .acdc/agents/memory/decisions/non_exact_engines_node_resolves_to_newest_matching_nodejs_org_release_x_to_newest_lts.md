---
name: 'Non-exact engines.node resolves to newest matching nodejs.org release, >=X to newest LTS'
description: 'Non-exact engines.node resolves to newest matching nodejs.org release, >=X to newest LTS'
type: decision
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources:
  - lib/utils.sh:42-133
  - bin/supply:29-35
  - README.md:11
---

## Compiled Truth

Decision: Non-exact engines.node specs resolve to the newest matching linux-x64 release in nodejs.org/dist/index.json; `>=X` resolves to the newest LTS; exact versions stay pinned with no lookup. Chosen by the maintainer (work item #12551).
Why: Resolving to the lowest match meant "22" installed 22.0.0 and ">=20.18.0" installed EOL 20.18.0, so apps never received Node security releases (e.g. https://nodejs.org/en/blog/vulnerability/october-2026-security-releases). Redeploying should pick up patches.
Rejected: (a) keep lowest-match and document that teams must pin patched versions; (b) keep lowest-match and only warn on EOL/outdated versions. Both leave apps with non-exact engines.node on unpatched Node until each team edits package.json; the maintainer chose newest-match without giving further reasons.
Accepted cost: staging needs nodejs.org/dist/index.json reachable for non-exact specs; `>=X` can jump majors (Node 26 becomes LTS on 2026-10-28).
Revisit when: customers stage without access to nodejs.org, or a major jump through `>=X` breaks apps.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->

---

## Timeline

- 2026-10-22 | Created: Non-exact engines.node resolves to newest matching nodejs.org release, >=X to newest LTS
