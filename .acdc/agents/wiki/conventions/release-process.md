---
title: 'Release process'
description: 'How a buildpack release is tagged and published on GitHub'
type: convention
sources:
  - CHANGELOG.md
  - "observed v1.4.0 release, 2026-10-22"
updated: 2026-10-22
confidence: medium
---

## Summary

The repository has no package.json, so `commit-and-tag-version` (the org default) does not apply. Releases are made by hand:

1. Add the version section to `CHANGELOG.md` by hand (Keep a Changelog format) in the feature branch, with a `chore(release): X.Y.Z #<WorkitemId>` commit.
2. After the PR is merged, create an annotated tag `vX.Y.Z` on the **master merge commit**, not on the feature branch, and push it.
3. Create a GitHub Release named after the tag, with the notes taken from the CHANGELOG section plus an upgrade note. A pushed tag alone does not create a GitHub Release.

## Links

- [CHANGELOG.md](../../../../CHANGELOG.md)
