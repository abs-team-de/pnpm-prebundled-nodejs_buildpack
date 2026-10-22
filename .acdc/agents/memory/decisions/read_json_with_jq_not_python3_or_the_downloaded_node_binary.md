---
name: 'Read JSON with jq, not python3 or the downloaded node binary'
description: 'Read JSON with jq, not python3 or the downloaded node binary'
type: decision
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources:
  - lib/utils.sh:13-35
  - bin/release:31
  - bin/supply:18-23
---

## Compiled Truth

Decision: All JSON handling (package.json, npm registry metadata, YAML escaping in bin/release) uses jq.
Why: jq ships on cflinuxfs4 (1.6) and cflinuxfs5 (1.7.1); keep filters 1.6-compatible.
Rejected: python3 because the stacks ship no interpreter; the downloaded node binary because it does not exist yet when bin/supply reads engines.node, and bin/release only receives BUILD_DIR (no deps dir with node).
Revisit when: a supported stack drops jq.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->

---

## Timeline

- 2026-10-22 | Created: Read JSON with jq, not python3 or the downloaded node binary
