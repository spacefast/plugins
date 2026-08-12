#!/usr/bin/env bash
# Continue after claim: exchange the saved space key — exactly once — for a
# durable, space-scoped access token, and rewrite .spacefast/state.json with it
# (the claimToken field is replaced by accessToken). Run this when a publish
# fails with error code space_claimed_credential_available; update.sh runs it
# automatically. Never prints either credential.
#
# Usage: continue.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$here/lib.sh"

if ! find_state; then
  printf 'error: no_saved_state\nhint: no .spacefast/state.json found here or above; nothing to exchange.\n' >&2
  exit 2
fi

if [ -n "$(state_value accessToken)" ]; then
  echo "State already holds a durable access token — nothing to exchange."
  exit 0
fi

claim_token="$(state_value claimToken)"
if [ -z "$claim_token" ]; then
  printf 'error: invalid_state\nhint: %s holds no claimToken; ask the user to create an API key in the dashboard (Account -> API keys).\n' "$STATE_FILE" >&2
  exit 2
fi

new_state_dir="$PROJECT_ROOT/.spacefast"
# Refuse unsafe persistence before spending the one-time space key.
persist_project_state verify "" "" ""
api_url="$(state_api_url)"
idempotency_key="$(continuation_idempotency_key "$claim_token")"
body="$(curl_auth_idempotent "$claim_token" "$idempotency_key" -X POST "$api_url/v1/claim/exchange")"
if ! check_envelope "$body"; then
  case "$LAST_ERROR_CODE" in
    continuation_used)
      body="$(curl_auth_idempotent "$claim_token" "$idempotency_key" -X POST "$api_url/v1/claim/exchange")"
      if check_envelope "$body"; then
        :
      else
        echo "The one-time exchange is not available. Ask the user to create an API key in the dashboard (Account -> API keys) and save it as \"accessToken\" in $STATE_FILE." >&2
        exit 1
      fi
      ;;
    continuation_unavailable)
      echo "The one-time exchange is not available. Ask the user to create an API key in the dashboard (Account -> API keys) and save it as \"accessToken\" in $STATE_FILE." >&2
      exit 1
      ;;
    *)
      exit 1
      ;;
  esac
fi

if have_jq; then
  access_token="$(printf '%s' "$body" | jq -r '.data.credential.accessToken // empty')"
  label="$(printf '%s' "$body" | jq -r '.data.credential.label // empty')"
  space_id="$(printf '%s' "$body" | jq -r '.data.space.id // empty')"
else
  access_token="$(json_field accessToken "$body")"
  label="$(json_field label "$body")"
  space_id="$(printf '%s' "$body" | grep -o '"spc_[A-Za-z0-9]*"' | head -n 1 | tr -d '"')"
fi
[ -n "$space_id" ] || space_id="$(state_value spaceId)"
validate_space_id "$space_id"
if [ -z "$access_token" ]; then
  printf 'error: unexpected_response\nhint: the exchange succeeded but no data.credential.accessToken was found in the response.\n' >&2
  exit 1
fi

version_id="$(state_value lastVersionId)"
if [ -n "$version_id" ]; then
  state_json="$(printf '{"spaceId":"%s","accessToken":"%s","apiUrl":"%s","lastVersionId":"%s"}' \
    "$space_id" "$access_token" "$api_url" "$version_id")"
else
  state_json="$(printf '{"spaceId":"%s","accessToken":"%s","apiUrl":"%s"}' \
    "$space_id" "$access_token" "$api_url")"
fi
persist_project_state merge "$state_json" claimToken "$space_id"

if [ -n "$label" ]; then
  echo "Exchanged the space key for a durable credential (\"$label\") and saved it to $new_state_dir/state.json. Retry the publish."
else
  echo "Exchanged the space key for a durable credential and saved it to $new_state_dir/state.json. Retry the publish."
fi
