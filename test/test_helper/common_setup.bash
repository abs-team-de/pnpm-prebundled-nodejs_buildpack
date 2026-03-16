#!/usr/bin/env bash
# ================================================================
# Shared setup and helpers for Bats tests
# ================================================================

# Resolve paths relative to the repo root
BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

setup_common() {
  TEST_TEMP="$(mktemp -d)"
  BUILD_DIR="${TEST_TEMP}/build"
  CACHE_DIR="${TEST_TEMP}/cache"
  DEPS_DIR="${TEST_TEMP}/deps"
  DEPS_IDX="0"
  mkdir -p "$BUILD_DIR" "$CACHE_DIR" "${DEPS_DIR}/${DEPS_IDX}"

  # Source shared utilities
  source "${BUILDPACK_DIR}/lib/utils.sh"
}

teardown_common() {
  rm -rf "$TEST_TEMP"
}

# ── Helpers ──────────────────────────────────────────────────────

create_package_json() {
  local dir="$1"
  shift
  # Accept raw JSON content as the second argument
  if [ $# -gt 0 ]; then
    echo "$1" > "${dir}/package.json"
  else
    cat > "${dir}/package.json" <<'JSON'
{
  "name": "test-app",
  "version": "1.0.0",
  "engines": { "node": "20.18.0" },
  "packageManager": "pnpm@9.15.4",
  "scripts": { "start": "node server.js" },
  "dependencies": { "express": "^4.18.0" }
}
JSON
  fi
}

create_node_modules() {
  local dir="$1"
  shift
  mkdir -p "${dir}/node_modules"
  # Create fake packages passed as arguments
  for pkg in "$@"; do
    mkdir -p "${dir}/node_modules/${pkg}"
    echo '{"name":"'"${pkg}"'","version":"1.0.0","main":"index.js"}' > "${dir}/node_modules/${pkg}/package.json"
    echo "module.exports = {};" > "${dir}/node_modules/${pkg}/index.js"
  done
}

create_symlinked_modules() {
  local dir="$1"
  shift
  mkdir -p "${dir}/node_modules"
  # Create a real package, then symlink others to it
  local real_pkg="_real_target"
  mkdir -p "${dir}/node_modules/${real_pkg}"
  echo '{"name":"'"${real_pkg}"'","version":"1.0.0"}' > "${dir}/node_modules/${real_pkg}/package.json"

  for pkg in "$@"; do
    ln -s "${dir}/node_modules/${real_pkg}" "${dir}/node_modules/${pkg}"
  done
}
