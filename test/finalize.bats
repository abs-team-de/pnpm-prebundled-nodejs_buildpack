#!/usr/bin/env bats
# ================================================================
# Tests for bin/finalize
#
# These tests run finalize in isolation by providing a minimal
# BUILD_DIR with the expected structure. Node.js must be available
# on PATH for the smoke test; we skip the node-dependent checks
# by not providing a resolvable dependency.
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
  # finalize needs node on PATH — use the system node if available
  export PATH="${DEPS_DIR}/${DEPS_IDX}/node/bin:${DEPS_DIR}/${DEPS_IDX}/bin:${PATH}"
}

teardown() {
  teardown_common
}

@test "finalize: passes with valid structure" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  # Create .bin directory to avoid find error
  mkdir -p "${BUILD_DIR}/node_modules/.bin"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Validation passed"* ]]
}

@test "finalize: fails when package.json is missing" {
  create_node_modules "$BUILD_DIR" express
  mkdir -p "${BUILD_DIR}/node_modules/.bin"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"package.json not found"* ]]
}

@test "finalize: fails when node_modules is missing" {
  create_package_json "$BUILD_DIR"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"node_modules/ directory not found"* ]]
}

@test "finalize: fails when node_modules contains symlinks" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  create_symlinked_modules "$BUILD_DIR" fake-link-a fake-link-b
  mkdir -p "${BUILD_DIR}/node_modules/.bin"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"symlinks in node_modules"* ]]
  [[ "$output" == *"indicates the bundle was created"* ]]
}

@test "finalize: fails when node_modules is empty" {
  create_package_json "$BUILD_DIR"
  mkdir -p "${BUILD_DIR}/node_modules"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"appears empty"* ]]
}

# ── Smoke test ───────────────────────────────────────────────────

@test "finalize: smoke test resolves the first dependency" {
  command -v node >/dev/null || skip "node not on PATH"
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Dependency smoke test passed (resolved 'express')"* ]]
}

@test "finalize: smoke test does not evaluate the dependency name as code" {
  command -v node >/dev/null || skip "node not on PATH"
  # Spliced into a JS string this would exit 0 before resolving anything
  create_package_json "$BUILD_DIR" "{\"name\":\"t\",\"dependencies\":{\"x'+process.exit(0)+'\":\"1\"}}"
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not resolve"* ]]
  [[ "$output" != *"smoke test passed"* ]]
}

@test "finalize: smoke test does not parse the dependency name as a node option" {
  command -v node >/dev/null || skip "node not on PATH"
  # Without an option terminator node would print its version and exit 0
  create_package_json "$BUILD_DIR" '{"name":"t","dependencies":{"--version":"1"}}'
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not resolve '--version'"* ]]
}
