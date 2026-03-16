#!/usr/bin/env bats
# ================================================================
# Tests for lib/utils.sh
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

# ── resolve_node_version ─────────────────────────────────────────

@test "resolve_node_version: exact version passes through" {
  run resolve_node_version "20.18.0"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: major only resolves to default when matching" {
  run resolve_node_version "20"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: major only resolves to X.0.0 for non-default" {
  run resolve_node_version "22"
  [ "$output" = "22.0.0" ]
}

@test "resolve_node_version: major.minor resolves to X.Y.0" {
  run resolve_node_version "20.18"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: .x wildcard on major" {
  run resolve_node_version "20.x"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: .x wildcard on minor" {
  run resolve_node_version "20.18.x"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: >= prefix stripped" {
  run resolve_node_version ">=20.18.0"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: ^ prefix stripped" {
  run resolve_node_version "^20.18.0"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: ~ prefix stripped" {
  run resolve_node_version "~20.18.0"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: empty string returns default" {
  run resolve_node_version ""
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: rejects range with space (>=20 <21)" {
  run resolve_node_version ">=20 <21"
  [ "$status" -eq 1 ]
}

@test "resolve_node_version: rejects OR range (18 || 20)" {
  run resolve_node_version "18 || 20"
  [ "$status" -eq 1 ]
}

@test "resolve_node_version: rejects hyphen range (18 - 20)" {
  run resolve_node_version "18 - 20"
  [ "$status" -eq 1 ]
}

@test "resolve_node_version: rejects lone star (*)" {
  run resolve_node_version "*"
  [ "$status" -eq 1 ]
}

# ── read_package_field ───────────────────────────────────────────

@test "read_package_field: reads top-level field" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "name"
  [ "$output" = "test-app" ]
}

@test "read_package_field: reads nested field (engines.node)" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "engines.node"
  [ "$output" = "20.18.0" ]
}

@test "read_package_field: reads scripts.start" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "scripts.start"
  [ "$output" = "node server.js" ]
}

@test "read_package_field: returns empty for missing field" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "nonexistent"
  [ "$output" = "" ]
}

@test "read_package_field: returns empty for missing file" {
  run read_package_field "${BUILD_DIR}/missing.json" "name"
  [ "$output" = "" ]
}

# ── read_first_dependency ────────────────────────────────────────

@test "read_first_dependency: returns first dependency" {
  create_package_json "$BUILD_DIR"
  run read_first_dependency "${BUILD_DIR}/package.json"
  [ "$output" = "express" ]
}

@test "read_first_dependency: returns empty when no dependencies" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0"}'
  run read_first_dependency "${BUILD_DIR}/package.json"
  [ "$output" = "" ]
}

@test "read_first_dependency: returns empty for missing file" {
  run read_first_dependency "${BUILD_DIR}/missing.json"
  [ "$output" = "" ]
}
