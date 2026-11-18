---
name: 'Concurrency groups keep one pending run: reconcile the major tag to the newest release, fetch it first'
description: 'Concurrency groups keep one pending run: reconcile the major tag to the newest release, fetch it first'
type: lesson
agent: nexus
created: 2026-11-18
reviewed: 2026-11-18
sources:
  - .github/workflows/major-tag.yml:6-55
---

## Compiled Truth

What happens: a GitHub Actions concurrency group with `cancel-in-progress: false` still keeps only one pending run; queuing a newer run cancels the older pending one. A job that moves the tag only "if my triggering release is the newest" can be cancelled exactly for the newest release and leave the tag behind. The newest tag may also have been published after the run's checkout.
How we found out: designing the major-tag workflow for v1.5.0; the Codex review found that a run otherwise failed with `fatal: Failed to resolve 'v1.5.0^{commit}'`.
What to do: reconcile on every run to the newest stable release of the triggering major (see .github/workflows/major-tag.yml). Remaining limit: the group is workflow-level and the prerelease `if:` only skips the job (major-tag.yml:6-21), so when any later run (a prerelease, or another major) replaces a queued stable run while the running job already picked an older release, the major tag stays one release behind until the next stable release of that major. Accepted: it needs three publications within one run's duration, and the next release heals it.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->
- relates-to: [moving major tag #v1](../decisions/apps_reference_the_buildpack_via_the_moving_major_tag_v1_moved_to_the_newest_stable_release.md) (EXTRACTED)

---

## Timeline

- 2026-11-18 | Created: Concurrency groups keep one pending run: reconcile the major tag to the newest release, fetch it first
