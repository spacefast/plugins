#!/usr/bin/env bash
# First publish: create an anonymous Spacefast space from a file or directory,
# save .spacefast/space.json + .spacefast/state.json so the next publish
# updates the same space, and print the live + claim URLs (never the token).
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

api_url="${SPACEFAST_API_URL:-$SPACEFAST_API_DEFAULT}"

build_upload "$target"
trap cleanup_upload EXIT INT TERM
if [ -n "${SPACEFAST_TOKEN:-}" ]; then
  echo "SPACEFAST_TOKEN is set — publishing authenticated instead of anonymous." >&2
  body="$(curl_auth "$SPACEFAST_TOKEN" "${UPLOAD_ARGS[@]}" -H "x-spacefast-client: agent/skill-script" "$api_url/v1/publish")"
else
  body="$(curl -sS "${UPLOAD_ARGS[@]}" -H "x-spacefast-client: agent/skill-script" "$api_url/v1/publish")"
fi
cleanup_upload
trap - EXIT INT TERM
check_envelope "$body" || exit 1
parse_receipt "$body"

if [ -n "$RECEIPT_SPACE_ID" ]; then
  mkdir -p .spacefast
  printf '{"space":"%s"}' "$RECEIPT_SPACE_ID" > .spacefast/space.json
  if [ -n "$RECEIPT_CLAIM_TOKEN" ]; then
    write_state_file .spacefast "$(
      printf '{"spaceId":"%s","claimToken":"%s","apiUrl":"%s","lastVersionId":"%s"}' \
        "$RECEIPT_SPACE_ID" "$RECEIPT_CLAIM_TOKEN" "$api_url" "$RECEIPT_VERSION_ID"
    )"
  fi
  ensure_gitignore .
fi

report_receipt
echo "Saved state to .spacefast/ — use update.sh for the next version of this space."
