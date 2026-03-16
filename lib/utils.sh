#!/usr/bin/env bash
# ================================================================
# pnpm-prebundled-nodejs_buildpack — shared utilities
# ================================================================

LOG_PREFIX="[pnpm-prebundled]"

log_info()   { echo "-----> ${LOG_PREFIX} $*"; }
log_detail() { echo "       $*"; }
log_warn()   { echo " !!    ${LOG_PREFIX} WARNING: $*"; }
log_error()  { echo " !!    ${LOG_PREFIX} ERROR: $*"; }

# ── Read fields from package.json using python3 (available on cflinuxfs4) ──
# Usage: read_package_field "/path/to/package.json" "dotted.key.path"
# Examples:
#   read_package_field pkg.json "name"              → package name
#   read_package_field pkg.json "engines.node"      → engines.node value
#   read_package_field pkg.json "packageManager"    → packageManager value
#   read_package_field pkg.json "scripts.start"     → start script
read_package_field() {
  local file="$1" field="$2"
  local result
  result=$(python3 -c "
import json, sys
try:
    data = json.load(open('${file}'))
    keys = '${field}'.split('.')
    val = data
    for k in keys:
        val = val[k]
    print(val)
except (KeyError, TypeError, FileNotFoundError, json.JSONDecodeError):
    pass
" 2>/dev/null || true)
  echo "$result"
}

# ── Get first dependency name from package.json ──
read_first_dependency() {
  local file="$1"
  local result
  result=$(python3 -c "
import json
try:
    data = json.load(open('${file}'))
    deps = data.get('dependencies', {})
    if deps:
        print(next(iter(deps)))
except (FileNotFoundError, json.JSONDecodeError, StopIteration):
    pass
" 2>/dev/null || true)
  echo "$result"
}

# ── Version defaults ──
NODE_DEFAULT_VERSION="20.18.0"
PNPM_DEFAULT_VERSION="9.15.4"

# ── Resolve a simple version constraint to a downloadable version ──
#
# Supported formats:
#   exact:    "20.18.0"
#   major:    "20"
#   minor:    "20.18"
#   wildcard: "20.x", "20.18.x"
#   prefix:   ">=20.18.0", "^20.18.0", "~20.18.0", ">=20"
#
# NOT supported (returns error via RESOLVE_ERROR):
#   ranges:   ">=18 <21", "18 || 20", "18 - 20"
#   star:     "*"
resolve_node_version() {
  local requested="$1"
  RESOLVE_ERROR=""

  if [ -z "$requested" ]; then
    echo "$NODE_DEFAULT_VERSION"
    return
  fi

  # Reject unsupported range expressions: spaces, ||, hyphen ranges, lone *
  if echo "$requested" | grep -qE '(\s|[|]{2}|[0-9]+\s*-\s*[0-9]+|^\*$)'; then
    RESOLVE_ERROR="Unsupported engines.node constraint: '${requested}'. Only exact versions (20.18.0), major (20), major.minor (20.18), wildcards (20.x), and single prefix operators (>=20, ^20.18.0, ~20.18.0) are supported."
    return 1
  fi

  # Strip leading semver operators and trailing .x
  local cleaned
  cleaned=$(echo "$requested" | sed 's/^[>=^~]*//' | sed 's/\.x//g')

  if [ -z "$cleaned" ]; then
    echo "$NODE_DEFAULT_VERSION"
    return
  fi

  # Reject if cleaned value contains non-version characters
  if ! echo "$cleaned" | grep -qE '^[0-9]+(\.[0-9]+){0,2}$'; then
    RESOLVE_ERROR="Unsupported engines.node constraint: '${requested}'. Could not extract a valid version number."
    return 1
  fi

  local dots
  dots=$(echo "$cleaned" | tr -cd '.' | wc -c)

  case "$dots" in
    0) # Major only, e.g. "20"
      local major="${cleaned}"
      local default_major="${NODE_DEFAULT_VERSION%%.*}"
      if [ "$major" = "$default_major" ]; then
        echo "$NODE_DEFAULT_VERSION"
      else
        echo "${major}.0.0"
      fi
      ;;
    1) # Major.minor, e.g. "20.18"
      echo "${cleaned}.0"
      ;;
    2) # Exact version, e.g. "20.18.0"
      echo "$cleaned"
      ;;
    *)
      RESOLVE_ERROR="Unsupported engines.node constraint: '${requested}'. Could not extract a valid version number."
      return 1
      ;;
  esac
}
