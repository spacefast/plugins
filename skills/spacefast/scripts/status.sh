#!/usr/bin/env bash
# Status: read (or poll) the anonymous publish/claim status for a version,
# authenticated with the saved claim token. Prints the status JSON; it may
# include a claim URL that embeds a pre-claim credential, so treat output as
# sensitive. Never prints the token itself.
#
# Usage: status.sh [versionId] [--wait]
#   versionId defaults to the lastVersionId saved by publish.sh/update.sh.
#   --wait polls every 3 seconds (up to 2 minutes) until the version is ready.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$here/lib.sh"

version_id=""
wait_mode=0
for arg in "$@"; do
  case "$arg" in
    --wait) wait_mode=1 ;;
    *) version_id="$arg" ;;
  esac
done

if ! find_state; then
  printf 'error: no_saved_state\nhint: no .spacefast/state.json found here or above; run publish.sh first.\n' >&2
  exit 2
fi

[ -n "$version_id" ] || version_id="$(state_value lastVersionId)"
if [ -z "$version_id" ]; then
  printf 'error: missing_version_id\nhint: pass a versionId (from the publish receipt); none is saved in state.\n' >&2
  exit 2
fi

api_url="$(state_api_url)"
cred="$(state_value claimToken)"
[ -n "$cred" ] || cred="$(state_value accessToken)"
if [ -z "$cred" ]; then
  printf 'error: invalid_state\nhint: %s holds no credential; re-run publish.sh.\n' "$STATE_FILE" >&2
  exit 2
fi

fetch_status() {
  curl_auth "$cred" "$api_url/v1/anonymous-claim/status?versionId=$version_id"
}

attempts=0
while :; do
  body="$(fetch_status)"
  check_envelope "$body" || exit 1
  if have_jq; then
    printf '%s' "$body" | jq '.data'
  else
    printf '%s\n' "$body"
  fi
  if [ "$wait_mode" -eq 0 ]; then
    break
  fi
  case "$(printf '%s' "$body" | tr -d ' ')" in
    *'"status":"ready"'* | *'"state":"claimed"'*) break ;;
  esac
  attempts=$((attempts + 1))
  if [ "$attempts" -ge 40 ]; then
    echo "Timed out waiting for the version to become ready; poll again later." >&2
    exit 1
  fi
  sleep 3
done
