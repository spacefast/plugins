#!/usr/bin/env bash
# First publish: create an anonymous Spacefast space from a file or directory,
# save .spacefast/space.json + .spacefast/state.json so the next publish
# updates the same space, and print the live + claim URLs (never the key).
#
# Usage: publish.sh [file-or-dir]   (defaults to the current directory)
#
# If saved state already exists (here or in a parent directory), this defers to
# update.sh instead of creating a duplicate space.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$here/lib.sh"

target="${1:-.}"

if find_state; then
  echo "Found existing Spacefast link at $STATE_DIR — publishing a new version to that space instead of creating a new one." >&2
  exec "$here/update.sh" "$target"
fi

capture_project_root .
api_url="$(trusted_api_url)"

build_upload "$target"
trap cleanup_upload EXIT INT TERM
attempt() {
  if [ -n "${SPACEFAST_TOKEN:-}" ]; then
    stream_upload |
      curl_auth "$SPACEFAST_TOKEN" "${UPLOAD_ARGS[@]}" \
        -H "x-spacefast-client: agent/skill-script" "$api_url/v1/publish"
  else
    stream_upload |
      curl -q -sS "${UPLOAD_ARGS[@]}" \
        -H "x-spacefast-client: agent/skill-script" "$api_url/v1/publish"
  fi
}
if [ -n "${SPACEFAST_TOKEN:-}" ]; then
  echo "SPACEFAST_TOKEN is set — publishing authenticated instead of anonymous." >&2
fi
body="$(attempt)"
cleanup_upload
trap - EXIT INT TERM
check_envelope "$body" || exit 1
parse_receipt "$body"

if [ -n "$RECEIPT_SPACE_ID" ]; then
  validate_space_id "$RECEIPT_SPACE_ID"
  if [ -n "$RECEIPT_CLAIM_TOKEN" ]; then
    persist_project_state replace "$(
      printf '{"spaceId":"%s","claimToken":"%s","apiUrl":"%s","lastVersionId":"%s"}' \
        "$RECEIPT_SPACE_ID" "$RECEIPT_CLAIM_TOKEN" "$api_url" "$RECEIPT_VERSION_ID"
    )" "" "$RECEIPT_SPACE_ID"
    # Reload the just-persisted issuer binding before the continuation poll;
    # curl_auth never sends even a fresh claim credential to an unbound origin.
    find_state
  else
    persist_project_state link "" "" "$RECEIPT_SPACE_ID"
  fi
fi

await_publish_receipt "$body" "${SPACEFAST_TOKEN:-}" "$api_url" || exit 1
report_receipt
echo "Saved state to .spacefast/ — use update.sh for the next version of this space."
