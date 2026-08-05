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
credential_source=state
if [ -n "${SPACEFAST_TOKEN:-}" ]; then
  cred="$SPACEFAST_TOKEN"
  credential_source=ambient
  api_url="$(trusted_api_url)"
elif [ -n "${SPACEFAST_API_URL:-}" ]; then
  printf 'error: unbound_credential\nhint: SPACEFAST_API_URL requires SPACEFAST_TOKEN; refusing to send a saved project credential to an ambient origin.\n' >&2
  exit 2
else
  cred="$(state_value accessToken)"
  [ -n "$cred" ] || cred="$(state_value claimToken)"
  api_url=""
  [ -z "$cred" ] || api_url="$(api_url_for_credential "$cred")"
fi
if [ -z "$space_id" ] || [ -z "$cred" ]; then
  printf 'error: invalid_state\nhint: this checkout is linked to space %s but you have no credential — set SPACEFAST_TOKEN or run sf login.\n' "${space_id:-unknown}" >&2
  exit 2
fi
validate_space_id "$space_id"

build_upload "$target"
trap cleanup_upload EXIT INT TERM
attempt() {
  stream_upload |
    curl_auth "$cred" "${UPLOAD_ARGS[@]}" --form-string "spaceId=$space_id" \
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

# Refresh the canonical .spacefast state captured during safe discovery.
new_state_dir="$PROJECT_ROOT/.spacefast"
access_token="$(state_value accessToken)"
claim_token="$(state_value claimToken)"
version_id="${RECEIPT_VERSION_ID:-$(state_value lastVersionId)}"
if [ "$credential_source" = ambient ]; then
  cred_field="$(printf '"accessToken":"%s"' "$cred")"
  delete_key=claimToken
elif [ -n "$access_token" ]; then
  cred_field="$(printf '"accessToken":"%s"' "$access_token")"
  delete_key=claimToken
elif [ -n "${SPACEFAST_TOKEN:-}" ] && [ -z "$claim_token" ]; then
  cred_field="$(printf '"accessToken":"%s"' "$SPACEFAST_TOKEN")"
  delete_key=claimToken
else
  cred_field="$(printf '"claimToken":"%s"' "$claim_token")"
  delete_key=""
fi
persist_project_state merge \
  "$(printf '{"spaceId":"%s",%s,"apiUrl":"%s","lastVersionId":"%s"}' "$space_id" "$cred_field" "$api_url" "$version_id")" \
  "$delete_key" "$space_id"

await_publish_receipt "$body" "$cred" "$api_url" || exit 1
report_receipt
