---
name: 'Verify buildpack changes inside the cflinuxfs stack images; host tests hid a missing python3'
description: 'Verify buildpack changes inside the cflinuxfs stack images; host tests hid a missing python3'
type: lesson
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources:
  - .github/workflows/ci.yml:26-38
  - test/test_helper/common_setup.bash:17-20
---

## Compiled Truth

What happens: The CF stack rootfs images (cflinuxfs5, and the cflinuxfs4 image built 2026-10-21; when cflinuxfs4 lost the interpreter is unknown) ship libpython but no python3 interpreter. The JSON reads in lib/utils.sh and the pnpm SHA1 lookup in bin/supply wrapped python3 in `2>/dev/null || true`, so each read returned empty with no error: engines.node was ignored and EOL Node 20.18.0 installed, and the pnpm checksum check was skipped. bin/release called python3 unsuppressed but never checked its exit status, so it logged 'python3: command not found' and still emitted `web: ` with no command. Host tests passed throughout because the host has python3.
How we found out: While updating Node.js for the October 2026 security release and checking cflinuxfs5 compatibility (#12551), the stack's package receipt listed libpython but no python3; running the bats suite inside the cloudfoundry/cflinuxfs5 image then failed 9 of 37 tests, all on python3 calls.
What to do: Run tests inside the cloudfoundry/cflinuxfs4 and cflinuxfs5 images (CI does) and check the stack's package receipt (receipt.cflinuxfs5.x86_64 in github.com/cloudfoundry/cflinuxfs5) before depending on a binary. Do not silence a required tool with `2>/dev/null || true` or ignore its exit status; fail staging when it is missing.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->

---

## Timeline

- 2026-10-22 | Created: Verify buildpack changes inside the cflinuxfs stack images; host tests hid a missing python3
