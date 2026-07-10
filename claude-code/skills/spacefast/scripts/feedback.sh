#!/usr/bin/env bash
set -euo pipefail

DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

json_escape() {
  node -e 'process.stdout.write(JSON.stringify(process.argv[1]).slice(1, -1))' "$1"
}

msg="${1:-}"
if [ -z "$msg" ]; then
  printf 'usage: %s "message" [category]\n' "$0" >&2
  exit 2
fi
category="${2:-other}"

space_id=""
claim_token=""
if find_state; then
  api_url="$(state_api_url)"
  space_id="$(state_value spaceId)"
  claim_token="$(state_value claimToken)"
else
  api_url="${SPACEFAST_API_URL:-$SPACEFAST_API_DEFAULT}"
fi

auth_header=()
if [ -n "${SPACEFAST_TOKEN:-}" ]; then
  auth_header=(-H "Authorization: Bearer $SPACEFAST_TOKEN")
elif [ -n "$claim_token" ]; then
  auth_header=(-H "Authorization: Bearer $claim_token")
fi

context='"context":{}'
if [ -n "$space_id" ]; then
  context="$(printf '"context":{"spaceId":"%s"}' "$space_id")"
fi

payload="$(printf '{"message":"%s","category":"%s",%s}' "$(json_escape "$msg")" "$(json_escape "$category")" "$context")"
curl -sS -X POST \
  -H "content-type: application/json" \
  "${auth_header[@]}" \
  -d "$payload" \
  "$api_url/v1/feedback"
