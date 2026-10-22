---
name: 'In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app'
description: 'In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app'
type: lesson
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources: ["npm-prebundled-nodejs_buildpack v1.0.0 acceptance run in cloudfoundry/cflinuxfs5, 2026-10-22, recorded in that repo's memory"]
---

## Compiled Truth

What happens: In the cloudfoundry/cflinuxfs4 and cflinuxfs5 docker images, /app is a symlink to /home/vcap/app. An end-to-end staging run of this buildpack that mounts an app with `-v ...:/app` and runs `cp -a /app dest` copies the symlink, not the app; Docker places the read-only bind mount at /home/vcap/app, so the next write into the build dir (supply's `mkdir .profile.d`, the package.json rewrite) fails with "Read-only file system".
How we found out: Not observed in this repo. Seen in the sibling npm-prebundled-nodejs_buildpack's v1.0.0 acceptance run in cloudfoundry/cflinuxfs5 on 2026-10-22 (recorded there): the copy produced `build -> /home/vcap/app`, and `mount` showed the bind mount at /home/vcap/app. The pnpm buildpack stages in the same images, so the same trap applies.
What to do: In any staging run inside those images, copy with `cp -a /app/. dest` (or read from /home/vcap/app).

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->
- relates-to: [Verify buildpack changes inside the cflinuxfs stack images; host tests hid a missing python3](verify_buildpack_changes_inside_the_cflinuxfs_stack_images_host_tests_hid_a_missing_python3.md) (INFERRED)

---

## Timeline

- 2026-10-22 | Created: In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app
