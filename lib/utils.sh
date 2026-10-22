#!/usr/bin/env bash
# ================================================================
# pnpm-prebundled-nodejs_buildpack — shared utilities
# ================================================================

LOG_PREFIX="[pnpm-prebundled]"

log_info()   { echo "-----> ${LOG_PREFIX} $*"; }
log_detail() { echo "       $*"; }
log_warn()   { echo " !!    ${LOG_PREFIX} WARNING: $*"; }
log_error()  { echo " !!    ${LOG_PREFIX} ERROR: $*"; }

# ── Read fields from package.json using jq (shipped on cflinuxfs4 and cflinuxfs5;
#    neither stack ships a python3 interpreter) ──
# Usage: read_package_field "/path/to/package.json" "dotted.key.path"
# Examples:
#   read_package_field pkg.json "name"              → package name
#   read_package_field pkg.json "engines.node"      → engines.node value
#   read_package_field pkg.json "packageManager"    → packageManager value
#   read_package_field pkg.json "scripts.start"     → start script
# Slurping (-s) makes jq parse the whole file before printing anything, so
# trailing garbage or a second document yields no output (like json.load).
read_package_field() {
  local file="$1" field="$2"
  jq -rs --arg field "$field" \
    'if length == 1 then (.[0] | getpath($field | split(".")))? // empty else empty end' \
    "$file" 2>/dev/null || true
}

# ── Get first dependency name from package.json ──
read_first_dependency() {
  local file="$1"
  jq -rs 'if length == 1 then (.[0].dependencies // {} | keys_unsorted[0])? // empty else empty end' \
    "$file" 2>/dev/null || true
}

# ── Version defaults ──
NODE_DEFAULT_VERSION="24.22.1"
PNPM_DEFAULT_VERSION="9.15.4"
NODE_INDEX_URL="${NODE_INDEX_URL:-https://nodejs.org/dist/index.json}"

# ── Resolve an engines.node constraint to a downloadable version ──
#
# Exact versions are used as-is (no network). Everything else resolves to
# the newest linux-x64 release on nodejs.org that satisfies it, so apps
# pick up security releases without changing package.json:
#   major / .x:  "24", "24.x"   → newest 24.*.*
#   minor / .x:  "24.3", "24.3.x" → newest 24.3.*
#   caret:       "^24.3.0"      → newest 24.*.* ≥ 24.3.0
#   tilde:       "~24.3.0"      → newest 24.3.* ≥ 24.3.0
#   lower bound: ">=20", ">20"  → newest LTS release ≥ 20.0.0
#
# NOT supported (error on stderr, returns 1):
#   ranges:   ">=18 <21", "18 || 20", "18 - 20"
#   star:     "*"
resolve_node_version() {
  local requested="$1"

  if [ -z "$requested" ]; then
    echo "$NODE_DEFAULT_VERSION"
    return
  fi

  # Reject unsupported range expressions: spaces, ||, hyphen ranges, lone *
  if echo "$requested" | grep -qE '(\s|[|]{2}|[0-9]+\s*-\s*[0-9]+|^\*$)'; then
    log_error "Unsupported engines.node constraint: '${requested}'. Only exact versions (24.22.1), major (24), major.minor (24.22), wildcards (24.x), and single prefix operators (>=24, ^24.22.1, ~24.22.1) are supported." >&2
    return 1
  fi

  # Split into leading semver operator and version (trailing .x stripped)
  local operator cleaned
  operator=$(echo "$requested" | sed 's/[0-9].*//')
  cleaned=$(echo "$requested" | sed 's/^[>=^~]*//' | sed 's/\.x//g')

  if [ -z "$cleaned" ]; then
    echo "$NODE_DEFAULT_VERSION"
    return
  fi

  if ! echo "$cleaned" | grep -qE '^[0-9]+(\.[0-9]+){0,2}$'; then
    log_error "Unsupported engines.node constraint: '${requested}'. Could not extract a valid version number." >&2
    return 1
  fi

  local parts
  parts=$(( $(echo "$cleaned" | tr -cd '.' | wc -c) + 1 ))

  case "$operator" in
    *">"*) operator=">=" ;;
    *"^"*) operator="^" ;;
    *"~"*) operator="~" ;;
    *)     operator="" ;;
  esac

  if [ -z "$operator" ] && [ "$parts" -eq 3 ]; then
    echo "$cleaned"
    return
  fi

  latest_node_version "$requested" "$operator" "$cleaned" "$parts"
}

# ── Newest nodejs.org linux-x64 release matching operator + version ──
# Usage: latest_node_version <requested> <operator> <version> <parts>
latest_node_version() {
  local requested="$1" operator="$2" version="$3" parts="$4"
  local index lower resolved

  if ! index=$(curl -sfL "$NODE_INDEX_URL"); then
    log_error "Could not fetch ${NODE_INDEX_URL} to resolve engines.node '${requested}'." >&2
    return 1
  fi

  # "24.3" → [24,3,0]
  lower=$(echo "${version}.0.0" | cut -d. -f1-3 | jq -R 'split(".") | map(tonumber)')

  resolved=$(echo "$index" | jq -r --arg op "$operator" --argjson low "$lower" --argjson parts "$parts" '
    [ .[]
      | select(any(.files[]; . == "linux-x64"))
      | {v: (.version | ltrimstr("v") | split(".") | map(tonumber)), lts}
      | select(.v >= $low)
      | select(
          if   $op == ">=" then .lts != false
          elif $op == "^"  then .v[0] == $low[0]
          elif $op == "~" and $parts >= 2 then .v[0:2] == $low[0:2]
          else .v[0:$parts] == $low[0:$parts] end)
    ] | (max_by(.v) // empty) | .v | map(tostring) | join(".")' 2>/dev/null || true)

  if [ -z "$resolved" ]; then
    log_error "No Node.js release on nodejs.org matches engines.node '${requested}'." >&2
    return 1
  fi
  echo "$resolved"
}
