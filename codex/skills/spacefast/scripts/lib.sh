#!/usr/bin/env bash
# Shared helpers for the Spacefast skill scripts. Sourced by publish.sh,
# update.sh, status.sh, and continue.sh — not meant to be run directly.
#
# Dependencies: bash, curl, and standard unix tools. jq is used when available;
# a sed/grep fallback covers the JSON these scripts read and write.
#
# Secrets discipline: claim tokens and access tokens are never printed, never
# put on a curl argv (bearer headers ride a stdin config), and state files are
# written with mode 0600.

SPACEFAST_API_DEFAULT="https://api.spacefast.com"
LAST_ERROR_CODE=""

have_jq() { command -v jq >/dev/null 2>&1; }

# Find the nearest state/link file, walking up from the current directory toward
# the filesystem root. A legacy .stattic/ directory (pre-rename checkouts)
# counts too. Sets STATE_DIR, STATE_FILE, STATE_LINK, PROJECT_ROOT, and
# STATE_KIND (state or link) when found.
find_state() {
  local dir="$PWD" name
  while :; do
    for name in .spacefast .stattic; do
      if [ -f "$dir/$name/state.json" ] || [ -f "$dir/$name/space.json" ]; then
        STATE_DIR="$dir/$name"
        STATE_FILE="$dir/$name/state.json"
        STATE_LINK="$dir/$name/space.json"
        PROJECT_ROOT="$dir"
        STATE_KIND="link"
        [ -f "$STATE_FILE" ] && STATE_KIND="state"
        return 0
      fi
    done
    [ "$dir" = "/" ] && return 1
    dir="$(dirname "$dir")"
  done
}

# json_field <key> <json-string> — first string value for a key, best effort
# without jq (fine for the flat state file and single-receipt lookups).
json_field() {
  local key="$1" input="$2"
  if have_jq; then
    printf '%s' "$input" |
      jq -r --arg k "$key" '[.. | objects | select(has($k)) | .[$k] | select(type == "string")] | first // empty' 2>/dev/null
  else
    printf '%s' "$input" | tr -d '\n' |
      grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n 1 |
      sed -n "s/^\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\"$/\1/p"
  fi
}

state_value() { # <key> — read a field from the discovered state file
  [ -f "$STATE_FILE" ] || return 0
  json_field "$1" "$(cat "$STATE_FILE")"
}

link_value() { # <key> — read a field from the discovered space link
  [ -f "$STATE_LINK" ] || return 0
  json_field "$1" "$(cat "$STATE_LINK")"
}

state_api_url() {
  local url
  url="$(state_value apiUrl)"
  printf '%s' "${url:-${SPACEFAST_API_URL:-$SPACEFAST_API_DEFAULT}}"
}

# Parse the symmetric {data}/{error} envelope. On an {error} envelope, print
# error.code + error.hint to stderr, record LAST_ERROR_CODE, and return 1.
check_envelope() {
  local body="$1" compact code hint
  compact="$(printf '%s' "$body" | tr -d ' \n\t\r')"
  case "$compact" in
    '{"error"'*)
      if have_jq; then
        code="$(printf '%s' "$body" | jq -r '.error.code // "unknown_error"')"
        hint="$(printf '%s' "$body" | jq -r '.error.hint // .error.message // empty')"
      else
        code="$(json_field code "$body")"
        code="${code:-unknown_error}"
        hint="$(json_field hint "$body")"
        [ -n "$hint" ] || hint="$(json_field message "$body")"
      fi
      LAST_ERROR_CODE="$code"
      printf 'error: %s\n' "$code" >&2
      [ -n "$hint" ] && printf 'hint: %s\n' "$hint" >&2
      return 1
      ;;
    '')
      LAST_ERROR_CODE="empty_response"
      printf 'error: empty_response\nhint: the API returned no body; retry or check connectivity.\n' >&2
      return 1
      ;;
  esac
  return 0
}

# curl with the bearer token kept off argv (argv is world-readable on shared
# hosts). The token rides a stdin curl config instead.
curl_auth() {
  local token="$1"
  shift
  curl -sS -K - "$@" <<EOF
header = "Authorization: Bearer $token"
EOF
}

curl_auth_idempotent() {
  local token="$1" idempotency_key="$2"
  shift 2
  curl -sS -K - "$@" <<EOF
header = "Authorization: Bearer $token"
header = "Idempotency-Key: $idempotency_key"
EOF
}

sha256_hex() {
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$1" | sha256sum | awk '{print $1}'
  else
    printf 'error: missing_sha256\nhint: install shasum or sha256sum to derive the exchange idempotency key.\n' >&2
    return 2
  fi
}

json_string_for_claim_token() {
  if have_jq; then
    jq -cn --arg claimToken "$1" '{claimToken:$claimToken}'
  else
    printf '{"claimToken":"%s"}' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  fi
}

continuation_idempotency_key() {
  # A hash failure inside command substitution would not stop the script, and
  # an empty digest would collide every exchange onto "sf-cont-". Verify the
  # digest before using it.
  local digest
  digest="$(sha256_hex "$(json_string_for_claim_token "$1")")" || digest=""
  if [ -z "$digest" ]; then
    printf 'error: missing_sha256\nhint: install shasum or sha256sum to derive the exchange idempotency key.\n' >&2
    return 1
  fi
  printf 'sf-cont-%s' "$digest"
}

# Write state JSON atomically with restrictive permissions.
write_state_file() { # <dir> <json>
  mkdir -p "$1"
  local tmp="$1/state.json.tmp.$$"
  (
    umask 077
    printf '%s' "$2" > "$tmp"
  )
  mv "$tmp" "$1/state.json"
  chmod 600 "$1/state.json" 2>/dev/null || true
}

merge_write_state_file() { # <dir> <json-patch>
  mkdir -p "$1"
  if have_jq && [ -f "$1/state.json" ]; then
    (
      umask 077
      jq -s '.[0] * .[1]' "$1/state.json" - <<<"$2" > "$1/state.json.tmp"
      mv "$1/state.json.tmp" "$1/state.json"
    )
    chmod 600 "$1/state.json" 2>/dev/null || true
  else
    # Without jq this falls back to a full rewrite of the keys this script
    # knows about; unknown fields cannot be preserved in the sed/grep-only path.
    write_state_file "$1" "$2"
  fi
}

ensure_gitignore() { # <project-root>
  local gi="$1/.gitignore"
  if [ -d "$1/.git" ] || [ -f "$gi" ]; then
    grep -qx '.spacefast/state.json' "$gi" 2>/dev/null ||
      printf '%s\n' '.spacefast/state.json' >> "$gi"
  fi
}

# Build the publish upload flags for a file or directory target. Directories
# are zipped with the shared secret/state exclusions (same list the skill's
# curl recipe uses). Sets UPLOAD_ARGS (array) and CLEANUP_ARCHIVE.
build_upload() { # <target>
  local target="$1"
  CLEANUP_ARCHIVE=""
  if [ -f "$target" ]; then
    UPLOAD_ARGS=(-F "files=@$target")
  elif [ -d "$target" ]; then
    CLEANUP_ARCHIVE="$(mktemp -d)/spacefast-site.zip"
    (
      cd "$target" &&
        zip -qr "$CLEANUP_ARCHIVE" . \
          -x ".env*" "*/.env*" ".npmrc" "*/.npmrc" ".netrc" "*/.netrc" ".git/*" "*/.git/*" ".spacefast/*" "*/.spacefast/*" ".ssh/*" "*/.ssh/*" ".aws/*" "*/.aws/*" ".kube/*" "*/.kube/*" ".docker/*" "*/.docker/*" "credentials.json" "*/credentials.json" "*.pem" "*/*.pem" "*.key" "*/*.key" "*.p12" "*/*.p12" "*.pfx" "*/*.pfx" "*.crt" "*/*.crt" "*id_rsa*" "*/*id_rsa*" ".stattic/*" "*/.stattic/*" "*.zip" "*.tar" "*.tgz"
    )
    UPLOAD_ARGS=(-F "archive=@$CLEANUP_ARCHIVE")
  else
    printf 'error: not_found\nhint: %s is not a file or directory.\n' "$target" >&2
    return 2
  fi
}

cleanup_upload() {
  [ -n "${CLEANUP_ARCHIVE:-}" ] && rm -rf "$(dirname "$CLEANUP_ARCHIVE")"
  return 0
}

# Pull the interesting fields out of a publish receipt. Sets RECEIPT_* vars.
# The claim token is extracted but must never be printed.
parse_receipt() { # <body>
  local body="$1" claim_section
  if have_jq; then
    RECEIPT_SPACE_ID="$(printf '%s' "$body" | jq -r '.data.space.id // empty')"
    RECEIPT_LIVE_URL="$(printf '%s' "$body" | jq -r '.data.space.liveUrl // empty')"
    RECEIPT_VERSION_ID="$(printf '%s' "$body" | jq -r '.data.version.id // empty')"
    RECEIPT_VERSION_URL="$(printf '%s' "$body" | jq -r '.data.version.immutableUrl // empty')"
    RECEIPT_CLAIM_TOKEN="$(printf '%s' "$body" | jq -r '.data.claim.token // empty')"
    RECEIPT_CLAIM_URL="$(printf '%s' "$body" | jq -r '.data.claim.url // empty')"
    RECEIPT_CLAIM_EXPIRES="$(printf '%s' "$body" | jq -r '.data.claim.expiresAt // empty')"
    RECEIPT_SHARE_BLURB="$(printf '%s' "$body" | jq -r '.data.shareBlurb // empty')"
  else
    RECEIPT_SPACE_ID="$(printf '%s' "$body" | grep -o '"spc_[A-Za-z0-9]*"' | head -n 1 | tr -d '"')"
    RECEIPT_VERSION_ID="$(printf '%s' "$body" | grep -o '"ver_[A-Za-z0-9]*"' | head -n 1 | tr -d '"')"
    RECEIPT_LIVE_URL="$(json_field liveUrl "$body")"
    RECEIPT_VERSION_URL="$(json_field immutableUrl "$body")"
    RECEIPT_SHARE_BLURB="$(json_field shareBlurb "$body")"
    claim_section="${body#*\"claim\"}"
    RECEIPT_CLAIM_TOKEN="$(json_field token "$claim_section")"
    RECEIPT_CLAIM_URL="$(json_field url "$claim_section")"
    RECEIPT_CLAIM_EXPIRES="$(json_field expiresAt "$claim_section")"
  fi
}

report_receipt() {
  [ -n "${RECEIPT_SPACE_ID:-}" ] && printf 'Space: %s\n' "$RECEIPT_SPACE_ID"
  [ -n "${RECEIPT_LIVE_URL:-}" ] && printf 'Live URL: %s\n' "$RECEIPT_LIVE_URL"
  [ -n "${RECEIPT_VERSION_URL:-}" ] && printf 'Version URL: %s\n' "$RECEIPT_VERSION_URL"
  if [ -n "${RECEIPT_CLAIM_URL:-}" ]; then
    printf 'Claim link (show the user; expires %s): %s\n' \
      "${RECEIPT_CLAIM_EXPIRES:-soon}" "$RECEIPT_CLAIM_URL"
  fi
  [ -n "${RECEIPT_SHARE_BLURB:-}" ] && printf '%s\n' "$RECEIPT_SHARE_BLURB"
  return 0
}
