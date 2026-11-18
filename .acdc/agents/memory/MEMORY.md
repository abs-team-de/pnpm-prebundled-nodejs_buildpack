# decisions
- [Apps reference the buildpack via the moving major tag #v1, moved to the newest stable release](decisions/apps_reference_the_buildpack_via_the_moving_major_tag_v1_moved_to_the_newest_stable_release.md)
- [Apps without engines.node get the default range 24.x, resolved at staging, not a pinned version](decisions/apps_without_engines_node_get_the_default_range_24_x_resolved_at_staging_not_a_pinned_version.md)
- [Read JSON with jq, not python3 or the downloaded node binary](decisions/read_json_with_jq_not_python3_or_the_downloaded_node_binary.md)
- [Non-exact engines.node resolves to newest matching nodejs.org release, >=X to newest LTS](decisions/non_exact_engines_node_resolves_to_newest_matching_nodejs_org_release_x_to_newest_lts.md)

# lessons
- [gh pr merge of a workflow-file change needs the workflow token scope, even with --admin](lessons/gh_pr_merge_of_a_workflow_file_change_needs_the_workflow_token_scope_even_with_admin.md)
- [Concurrency groups keep one pending run: reconcile the major tag to the newest release, fetch it first](lessons/concurrency_groups_keep_one_pending_run_reconcile_the_major_tag_to_the_newest_release_fetch_it_first.md)
- [In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app](lessons/in_cflinuxfs_images_app_is_a_symlink_copy_its_contents_not_the_link.md)
- [Errors set in a global inside $(...) are lost in the subshell; report on stderr and test the exit status](lessons/errors_set_in_a_global_inside_are_lost_in_the_subshell_report_on_stderr_and_test_the_exit_status.md)
- [Verify buildpack changes inside the cflinuxfs stack images; host tests hid a missing python3](lessons/verify_buildpack_changes_inside_the_cflinuxfs_stack_images_host_tests_hid_a_missing_python3.md)
