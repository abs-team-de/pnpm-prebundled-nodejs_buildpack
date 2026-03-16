#!/usr/bin/env bash
# ================================================================
# pnpm-prebundled-nodejs_buildpack — shared utilities
# ================================================================

LOG_PREFIX="[pnpm-prebundled]"

log_info()   { echo "-----> ${LOG_PREFIX} $*"; }
log_detail() { echo "       $*"; }
log_warn()   { echo " !!    ${LOG_PREFIX} WARNING: $*"; }
log_error()  { echo " !!    ${LOG_PREFIX} ERROR: $*"; }

# ── Read a field from package.json (no jq dependency) ──
# Usage: read_package_field "/path/to/package.json" "fieldName"
read_package_field() {
  local file="$1" field="$2"
  grep "\"${field}\"" "$file" 2>/dev/null \
    | head -1 \
    | sed 's/.*: *"\([^"]*\)".*/\1/'
}

# ── Version defaults ──
NODE_DEFAULT_VERSION="20.18.0"
PNPM_DEFAULT_VERSION="9.15.4"

# ── Resolve a semver-like constraint to a downloadable version ──
# Supports: "20", "20.x", "20.18.x", ">=20", "^20.18.0", "~20.18.0", exact "20.18.0"
resolve_node_version() {
  local requested="$1"

  # Strip leading semver operators and trailing .x
  local cleaned
  cleaned=$(echo "$requested" | sed 's/^[>=^~]*//' | sed 's/\.x//g')

  if [ -z "$cleaned" ]; then
    echo "$NODE_DEFAULT_VERSION"
    return
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
      echo "$NODE_DEFAULT_VERSION"
      ;;
  esac
}
