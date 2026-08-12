#!/usr/bin/env bash
# Persist a direct-publish JSON receipt through the same hardened state writer
# used by publish.sh. The complete receipt is read from stdin so space keys
# never appear on argv.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$here/lib.sh"

capture_project_root .
body=""
while IFS= read -r line || [ -n "$line" ]; do
  [ -z "$body" ] || body="$body
"
  body="$body$line"
done
check_envelope "$body" || exit 1
parse_receipt "$body"
space_suffix="${RECEIPT_SPACE_ID#spc_}"
if [ "$space_suffix" = "$RECEIPT_SPACE_ID" ] || [ -z "$space_suffix" ] ||
  case "$space_suffix" in *[!A-Za-z0-9]*) true ;; *) false ;; esac
then
  printf 'error: unexpected_response\nhint: the publish receipt did not contain a valid data.space.id.\n' >&2
  exit 2
fi
if [ -z "$RECEIPT_CLAIM_TOKEN" ]; then
  printf 'error: unexpected_response\nhint: the publish receipt did not contain data.claim.key; use authenticated CLI state instead.\n' >&2
  exit 2
fi

api_url="$(trusted_api_url)"
if have_jq; then
  state_json="$(
    jq -cn \
      --arg spaceId "$RECEIPT_SPACE_ID" \
      --arg claimToken "$RECEIPT_CLAIM_TOKEN" \
      --arg apiUrl "$api_url" \
      --arg lastVersionId "$RECEIPT_VERSION_ID" \
      '{spaceId:$spaceId,claimToken:$claimToken,apiUrl:$apiUrl,lastVersionId:$lastVersionId}'
  )"
else
  for state_value in "$RECEIPT_CLAIM_TOKEN" "$RECEIPT_VERSION_ID"; do
    if printf '%s' "$state_value" | LC_ALL=C grep -q '[^A-Za-z0-9_.-]'; then
      printf 'error: invalid_receipt_value\nhint: install jq to persist a receipt containing escaped JSON values.\n' >&2
      exit 2
    fi
  done
  state_json="$(
    printf '{"spaceId":"%s","claimToken":"%s","apiUrl":"%s","lastVersionId":"%s"}' \
      "$RECEIPT_SPACE_ID" "$RECEIPT_CLAIM_TOKEN" "$api_url" "$RECEIPT_VERSION_ID"
  )"
fi
persist_project_state replace "$state_json" "" "$RECEIPT_SPACE_ID"
printf 'Saved direct-publish state for %s without printing its credential.\n' "$RECEIPT_SPACE_ID"
