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
