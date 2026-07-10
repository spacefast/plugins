#!/usr/bin/env bash
# Update: publish a new version to the space saved in .spacefast/state.json
# (never creates a new space). If the user has claimed the space since the last
# publish, the publish fails once with space_claimed_credential_available; this
# script then runs continue.sh to exchange the claim token for a durable key
# and retries automatically.
#
# Usage: update.sh [file-or-dir]   (defaults to the current directory)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$here/lib.sh"

target="${1:-.}"

if ! find_state; then
  printf 'error: no_saved_state\nhint: no .spacefast/state.json found here or above; run publish.sh for a first publish.\n' >&2
  exit 2
fi

space_id="$(state_value spaceId)"
[ -n "$space_id" ] || space_id="$(link_value space)"
api_url="$(state_api_url)"
link_api_url="$(link_value apiBaseUrl)"
[ -n "$link_api_url" ] && api_url="$link_api_url"
cred="$(state_value accessToken)"
[ -n "$cred" ] || cred="$(state_value claimToken)"
[ -n "$cred" ] || cred="${SPACEFAST_TOKEN:-}"
if [ -z "$space_id" ] || [ -z "$cred" ]; then
  printf 'error: invalid_state\nhint: this checkout is linked to space %s but you have no credential — set SPACEFAST_TOKEN or run sf login.\n' "${space_id:-unknown}" >&2
  exit 2
fi
case "$space_id" in
  spc_*) ;;
  *)
    resolved="$(curl_auth "$cred" "$api_url/v1/spaces/resolve?ref=$space_id")"
    check_envelope "$resolved" || exit 1
    space_id="$(json_field id "$resolved")"
    if [ -z "$space_id" ]; then
      printf 'error: unresolved_space_link\nhint: could not resolve the linked space from %s.\n' "$STATE_LINK" >&2
      exit 1
    fi
    ;;
esac

build_upload "$target"
trap cleanup_upload EXIT INT TERM
attempt() {
  curl_auth "$cred" "${UPLOAD_ARGS[@]}" -F "spaceId=$space_id" \
    -H "x-spacefast-client: agent/skill-script" "$api_url/v1/publish"
}

body="$(attempt)"
if ! check_envelope "$body"; then
  if [ "$LAST_ERROR_CODE" = "space_claimed_credential_available" ]; then
    echo "The user claimed this space — exchanging the claim token for a durable key, then retrying." >&2
    "$here/continue.sh"
    find_state
    cred="$(state_value accessToken)"
    body="$(attempt)"
    check_envelope "$body" || {
      cleanup_upload
      exit 1
    }
  else
    cleanup_upload
    exit 1
  fi
fi
cleanup_upload
trap - EXIT INT TERM

parse_receipt "$body"

# Refresh state (and migrate a legacy .stattic/ dir to .spacefast/).
new_state_dir="$PROJECT_ROOT/.spacefast"
access_token="$(state_value accessToken)"
claim_token="$(state_value claimToken)"
version_id="${RECEIPT_VERSION_ID:-$(state_value lastVersionId)}"
if [ -n "$access_token" ]; then
  cred_field="$(printf '"accessToken":"%s"' "$access_token")"
elif [ -n "${SPACEFAST_TOKEN:-}" ] && [ -z "$claim_token" ]; then
  cred_field="$(printf '"accessToken":"%s"' "$SPACEFAST_TOKEN")"
else
  cred_field="$(printf '"claimToken":"%s"' "$claim_token")"
fi
merge_write_state_file "$new_state_dir" \
  "$(printf '{"spaceId":"%s",%s,"apiUrl":"%s","lastVersionId":"%s"}' "$space_id" "$cred_field" "$api_url" "$version_id")"
printf '{"space":"%s"}' "$space_id" > "$new_state_dir/space.json"
ensure_gitignore "$PROJECT_ROOT"
if [ "$STATE_DIR" != "$new_state_dir" ]; then
  echo "Migrated legacy state from $STATE_DIR to $new_state_dir." >&2
  case "$STATE_DIR" in
    */.stattic) rm -f "$STATE_DIR/state.json" ;;
  esac
fi

report_receipt
