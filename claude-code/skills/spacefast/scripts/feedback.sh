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
  space_id="$(state_value spaceId)"
  claim_token="$(state_value claimToken)"
fi
[ -z "$space_id" ] || validate_space_id "$space_id"

if [ -n "${SPACEFAST_TOKEN:-}" ]; then
  credential="$SPACEFAST_TOKEN"
elif [ -n "$claim_token" ]; then
  credential="$claim_token"
else
  credential=""
fi
api_url="${credential:+$(api_url_for_credential "$credential")}"
[ -n "$api_url" ] || api_url="$(trusted_api_url)"

context='"context":{}'
if [ -n "$space_id" ]; then
  context="$(printf '"context":{"spaceId":"%s"}' "$space_id")"
fi

payload="$(printf '{"message":"%s","category":"%s",%s}' "$(json_escape "$msg")" "$(json_escape "$category")" "$context")"
request_args=(-X POST -H "content-type: application/json" -d "$payload" "$api_url/v1/feedback")
if [ -n "$credential" ]; then
  curl_auth "$credential" "${request_args[@]}"
else
  curl -q -sS "${request_args[@]}"
fi
