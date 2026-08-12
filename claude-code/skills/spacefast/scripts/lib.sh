#!/usr/bin/env bash
# Shared helpers for the Spacefast skill scripts. Sourced by publish.sh,
# update.sh, status.sh, and continue.sh — not meant to be run directly.
#
# Dependencies: bash, curl, and standard unix tools. jq is used when available;
# a sed/grep fallback covers the JSON these scripts read and write.
#
# Secrets discipline: space keys and access tokens are never printed, never
# put on a curl argv (bearer headers ride a stdin config), and state files are
# written with mode 0600.

SPACEFAST_API_DEFAULT="https://api.spacefast.com"
LAST_ERROR_CODE=""

have_jq() { command -v jq >/dev/null 2>&1; }

trusted_python() {
  local candidate
  for candidate in \
    /usr/bin/python3.14 /usr/bin/python3.13 /usr/bin/python3.12 \
    /usr/bin/python3.11 /usr/bin/python3.10 /usr/bin/python3.9 /usr/bin/python3.8 \
    /usr/local/bin/python3.14 /usr/local/bin/python3.13 /usr/local/bin/python3.12 \
    /usr/local/bin/python3.11 /usr/local/bin/python3.10 /usr/local/bin/python3.9 \
    /opt/homebrew/bin/python3 /opt/homebrew/bin/python3.14 /opt/homebrew/bin/python3.13 \
    /opt/homebrew/bin/python3.12 /opt/homebrew/bin/python3.11 /opt/homebrew/bin/python3.10 \
    /opt/homebrew/bin/python3.9
  do
    case "$candidate" in
      /opt/homebrew/*)
        if [ -x "$candidate" ] && [ -f "$candidate" ] &&
          reject_symlink_components "${candidate%/*}" runtime >/dev/null 2>&1
        then
          printf '%s' "$candidate"
          return 0
        fi
        continue
        ;;
    esac
    if [ -x "$candidate" ] && [ -f "$candidate" ] && [ ! -L "$candidate" ] &&
      reject_symlink_components "$candidate" runtime >/dev/null 2>&1
    then
      printf '%s' "$candidate"
      return 0
    fi
  done
  printf 'error: missing_secure_writer\nhint: python3 is required for no-follow state and archive operations.\n' >&2
  return 2
}

# Find the nearest state/link file, walking up from the current directory toward
# the filesystem root. Discovery opens the original lexical working directory
# from / with O_NOFOLLOW descriptors, rejects hardlinked files, and snapshots
# both JSON documents so later reads never reopen a repository-controlled path.
# Sets STATE_DIR, STATE_FILE, STATE_LINK, PROJECT_ROOT, STATE_KIND, STATE_JSON,
# LINK_JSON, STATE_PROJECT_ID, STATE_FILE_ID, and STATE_LINK_ID when found.
find_state() {
  local secure_python discovered status sentinel
  secure_python="$(trusted_python)" || return
  set +e
  discovered="$("$secure_python" -I -c '
import json, os, stat, sys

directory_flags = os.O_RDONLY | os.O_DIRECTORY
directory_flags |= getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)
file_flags = os.O_RDONLY | getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)

def lexical(path):
    normalized = os.path.normpath(path if os.path.isabs(path) else os.path.join(os.getcwd(), path))
    if not normalized.startswith("/"):
        raise RuntimeError("state path must be absolute")
    if any(ord(character) < 32 or character == "\t" for character in normalized):
        raise RuntimeError("state path contains control characters")
    return normalized

def open_lexical_directory(path):
    fd = os.open("/", directory_flags)
    try:
        for component in [part for part in path.split("/") if part]:
            next_fd = os.open(component, directory_flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        return fd
    except BaseException:
        os.close(fd)
        raise

def identity(info):
    return f"{info.st_dev}:{info.st_ino}"

def read_json(directory_fd, name):
    try:
        fd = os.open(name, file_flags, dir_fd=directory_fd)
    except FileNotFoundError:
        return None, "missing"
    try:
        info = os.fstat(fd)
        entry = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
            raise RuntimeError(f"{name} must be a singly linked regular file")
        if (entry.st_dev, entry.st_ino) != (info.st_dev, info.st_ino):
            raise RuntimeError(f"{name} changed while opening")
        chunks = []
        total = 0
        while True:
            chunk = os.read(fd, 65536)
            if not chunk:
                break
            total += len(chunk)
            if total > 1024 * 1024:
                raise RuntimeError(f"{name} is too large")
            chunks.append(chunk)
        final = os.fstat(fd)
        entry = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if (final.st_dev, final.st_ino) != (info.st_dev, info.st_ino):
            raise RuntimeError(f"{name} changed while reading")
        if (entry.st_dev, entry.st_ino) != (info.st_dev, info.st_ino):
            raise RuntimeError(f"{name} was replaced while reading")
        value = json.loads(b"".join(chunks).decode("utf-8"))
        if not isinstance(value, dict):
            raise RuntimeError(f"{name} must contain a JSON object")
        return json.dumps(value, separators=(",", ":"), ensure_ascii=True), identity(info)
    finally:
        os.close(fd)

try:
    current_path = lexical(sys.argv[1])
    current_fd = open_lexical_directory(current_path)
    try:
        while True:
            try:
                state_dir_fd = os.open(".spacefast", directory_flags, dir_fd=current_fd)
            except FileNotFoundError:
                state_dir_fd = None
            if state_dir_fd is not None:
                try:
                    state_json, state_id = read_json(state_dir_fd, "state.json")
                    link_json, link_id = read_json(state_dir_fd, "space.json")
                    if state_json is not None or link_json is not None:
                        root_info = os.fstat(current_fd)
                        fields = [
                            current_path,
                            identity(root_info),
                            state_id,
                            link_id,
                            state_json or "{}",
                            link_json or "{}",
                            "found",
                        ]
                        print("\t".join(fields))
                        raise SystemExit(0)
                finally:
                    os.close(state_dir_fd)
            current_info = os.fstat(current_fd)
            parent_fd = os.open("..", directory_flags, dir_fd=current_fd)
            parent_info = os.fstat(parent_fd)
            if (parent_info.st_dev, parent_info.st_ino) == (current_info.st_dev, current_info.st_ino):
                os.close(parent_fd)
                raise SystemExit(1)
            os.close(current_fd)
            current_fd = parent_fd
            current_path = os.path.dirname(current_path)
    finally:
        os.close(current_fd)
except SystemExit:
    raise
except BaseException as error:
    print(f"error: unsafe_state_path\nhint: {error}", file=sys.stderr)
    raise SystemExit(2)
' "$PWD")"
  status=$?
  set -e
  [ "$status" -eq 0 ] || return "$status"
  IFS=$'\t' read -r PROJECT_ROOT STATE_PROJECT_ID STATE_FILE_ID STATE_LINK_ID STATE_JSON LINK_JSON sentinel <<<"$discovered"
  [ "$sentinel" = found ] || return 2
  STATE_DIR="$PROJECT_ROOT/.spacefast"
  STATE_FILE="$STATE_DIR/state.json"
  STATE_LINK="$STATE_DIR/space.json"
  STATE_KIND=link
  [ "$STATE_FILE_ID" = missing ] || STATE_KIND=state
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
  [ -n "${STATE_JSON:-}" ] || return 0
  json_field "$1" "$STATE_JSON"
}

link_value() { # <key> — read a field from the discovered space link
  [ -n "${LINK_JSON:-}" ] || return 0
  json_field "$1" "$LINK_JSON"
}

capture_project_root() { # <project-root>
  local secure_python captured status sentinel
  secure_python="$(trusted_python)" || return
  set +e
  captured="$("$secure_python" -I -c '
import os, sys

flags = os.O_RDONLY | os.O_DIRECTORY
flags |= getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)
path = os.path.normpath(sys.argv[1] if os.path.isabs(sys.argv[1]) else os.path.join(os.getcwd(), sys.argv[1]))
try:
    if any(ord(character) < 32 or character == "\t" for character in path):
        raise RuntimeError("project path contains control characters")
    fd = os.open("/", flags)
    try:
        for component in [part for part in path.split("/") if part]:
            next_fd = os.open(component, flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        info = os.fstat(fd)
        print(f"{path}\t{info.st_dev}:{info.st_ino}\tcaptured")
    finally:
        os.close(fd)
except BaseException as error:
    print(f"error: unsafe_state_path\nhint: {error}", file=sys.stderr)
    raise SystemExit(2)
' "$1")"
  status=$?
  set -e
  [ "$status" -eq 0 ] || return "$status"
  IFS=$'\t' read -r PROJECT_ROOT STATE_PROJECT_ID sentinel <<<"$captured"
  [ "$sentinel" = captured ] || return 2
  STATE_FILE_ID=missing
  STATE_LINK_ID=missing
  STATE_DIR="$PROJECT_ROOT/.spacefast"
  STATE_FILE="$STATE_DIR/state.json"
  STATE_LINK="$STATE_DIR/space.json"
  STATE_JSON='{}'
  LINK_JSON='{}'
}

validate_space_id() { # <space-id>
  case "$1" in
    spc_?*)
      case "${1#spc_}" in *[!A-Za-z0-9]*) ;; *) return 0 ;; esac
      ;;
  esac
  printf 'error: invalid_space_id\nhint: expected a canonical spc_ identifier.\n' >&2
  return 2
}

validate_operation_id() { # <operation-id>
  case "$1" in
    op_?*)
      case "${1#op_}" in *[!A-Za-z0-9]*) ;; *) return 0 ;; esac
      ;;
  esac
  printf 'error: invalid_operation_id\nhint: the publish receipt did not contain a canonical operation id.\n' >&2
  return 2
}

normalize_api_origin() { # <url>
  local url="$1" scheme remainder authority
  if printf '%s' "$url" | LC_ALL=C grep -q '[[:cntrl:][:space:]]'; then
    printf 'error: invalid_api_url\nhint: API URLs cannot contain whitespace or control characters.\n' >&2
    return 2
  fi
  case "$url" in
    http://* | https://*) ;;
    *)
      printf 'error: invalid_api_url\nhint: API URLs must use http:// or https://.\n' >&2
      return 2
      ;;
  esac
  scheme="${url%%:*}"
  remainder="${url#*://}"
  authority="${remainder%%/*}"
  authority="${authority%%\?*}"
  authority="${authority%%\#*}"
  if [ -z "$authority" ] || [ "$authority" != "${authority#*@}" ]; then
    printf 'error: invalid_api_url\nhint: API URLs must name an origin without embedded credentials.\n' >&2
    return 2
  fi
  printf '%s://%s' "$scheme" "$authority"
}

trusted_api_url() {
  normalize_api_origin "${SPACEFAST_API_URL:-$SPACEFAST_API_DEFAULT}"
}

state_api_url() {
  local url
  url="$(state_value apiUrl)"
  if [ -n "$url" ]; then
    normalize_api_origin "$url"
  else
    trusted_api_url
  fi
}

# Ambient tokens are bound only to an API origin selected independently of
# repository state. Saved state credentials remain bound to the origin stored
# alongside them, matching the main CLI's credential issuer behavior.
api_url_for_credential() { # <token>
  local token="$1" saved_access saved_claim
  if [ -n "${SPACEFAST_TOKEN:-}" ] && [ "$token" = "$SPACEFAST_TOKEN" ]; then
    trusted_api_url
    return
  fi
  saved_access="$(state_value accessToken)"
  saved_claim="$(state_value claimToken)"
  if { [ -n "$saved_access" ] && [ "$token" = "$saved_access" ]; } ||
    { [ -n "$saved_claim" ] && [ "$token" = "$saved_claim" ]; }
  then
    state_api_url
    return
  fi
  printf 'error: unbound_credential\nhint: refusing to send a credential without a trusted API origin.\n' >&2
  return 2
}

validate_curl_config_value() { # <value> <label>
  local value="$1" label="$2"
  if [ -z "$value" ] ||
    printf '%s' "$value" | LC_ALL=C grep -q '[[:cntrl:]]' ||
    case "$value" in *'"'* | *'\\'*) true ;; *) false ;; esac
  then
    printf 'error: invalid_%s\nhint: refusing a value that is unsafe for curl configuration.\n' "$label" >&2
    return 2
  fi
}

assert_authenticated_destination() { # <token> <curl args...>
  local token="$1" argument request_count=0 expected_origin actual_origin
  shift
  expected_origin="$(api_url_for_credential "$token")" || return
  for argument in "$@"; do
    case "$argument" in
      http://* | https://*)
        request_count=$((request_count + 1))
        actual_origin="$(normalize_api_origin "$argument")" || return
        if [ "$actual_origin" != "$expected_origin" ]; then
          printf 'error: credential_origin_mismatch\nhint: refusing to send a credential to an API origin selected by project state.\n' >&2
          return 2
        fi
        ;;
    esac
  done
  if [ "$request_count" -eq 0 ]; then
    printf 'error: missing_api_url\nhint: authenticated requests require an explicit API URL.\n' >&2
    return 2
  fi
}

# Successes are {data}; failures are RFC 9457 problem documents, recognised by a
# top-level `code`. On a problem document, print code + detail to stderr, record
# LAST_ERROR_CODE, and return 1.
check_envelope() {
  local body="$1" compact code detail
  compact="$(printf '%s' "$body" | tr -d ' \n\t\r')"
  if [ -z "$compact" ]; then
    LAST_ERROR_CODE="empty_response"
    printf 'error: empty_response\nhint: the API returned no body; retry or check connectivity.\n' >&2
    return 1
  fi
  if have_jq; then
    printf '%s' "$body" | jq -e 'type == "object" and (.code | type == "string")' >/dev/null 2>&1 ||
      return 0
    code="$(printf '%s' "$body" | jq -r '.code')"
    detail="$(printf '%s' "$body" | jq -r '.detail // .title // empty')"
  else
    case "$compact" in
      '{"data"'*) return 0 ;;
      *'"code":"'*) ;;
      *) return 0 ;;
    esac
    code="$(json_field code "$body")"
    code="${code:-unknown_error}"
    detail="$(json_field detail "$body")"
    [ -n "$detail" ] || detail="$(json_field title "$body")"
  fi
  LAST_ERROR_CODE="$code"
  printf 'error: %s\n' "$code" >&2
  [ -n "$detail" ] && printf 'hint: %s\n' "$detail" >&2
  return 1
}

# curl with the bearer token kept off argv (argv is world-readable on shared
# hosts). The token rides a stdin curl config instead.
curl_auth() {
  local token="$1"
  shift
  validate_curl_config_value "$token" credential || return
  assert_authenticated_destination "$token" "$@" || return
  curl -q -sS -K /dev/fd/3 "$@" 3<<EOF
header = "Authorization: Bearer $token"
EOF
}

curl_auth_idempotent() {
  local token="$1" idempotency_key="$2"
  shift 2
  validate_curl_config_value "$token" credential || return
  validate_curl_config_value "$idempotency_key" idempotency_key || return
  assert_authenticated_destination "$token" "$@" || return
  curl -q -sS -K /dev/fd/3 "$@" 3<<EOF
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

# Reject every symlink in a lexical path before a sensitive read or write.
reject_symlink_components() { # <path> <purpose>
  local path="$1" purpose="$2" lexical remaining component current candidate
  case "$path" in
    /*) lexical="$path" ;;
    *) lexical="$PWD/$path" ;;
  esac
  remaining="${lexical#/}"
  current="/"
  while [ -n "$remaining" ]; do
    case "$remaining" in
      */*) component="${remaining%%/*}"; remaining="${remaining#*/}" ;;
      *) component="$remaining"; remaining="" ;;
    esac
    case "$component" in
      "" | ".") continue ;;
      "..") current="${current%/*}"; [ -n "$current" ] || current="/"; continue ;;
    esac
    if [ "$current" = "/" ]; then candidate="/$component"; else candidate="$current/$component"; fi
    if [ -L "$candidate" ]; then
      printf 'error: unsafe_symlink\nhint: remove symbolic link %s from the %s path.\n' "$candidate" "$purpose" >&2
      return 2
    fi
    current="$candidate"
  done
}

persist_project_state() { # <replace|merge|verify> <json-or-empty> <delete-key> <space-id-or-empty>
  local operation="$1" contents="$2" delete_key="$3" space_id="$4" secure_python
  [ -z "$space_id" ] || validate_space_id "$space_id" || return
  secure_python="$(trusted_python)" || return
  # The entire lifecycle stays under one root descriptor: directory creation and
  # mode repair, identity-bound existing reads, merge, exclusive temp creation,
  # link-count/identity checks, atomic replacement, and identity-bound cleanup.
  # Secret state bytes ride stdin, never argv or a named shell temporary.
  printf '%s' "$contents" | "$secure_python" -I -c '
import json, os, secrets, stat, sys

project_path, expected_root, expected_state, expected_link, operation, delete_key, space_id = sys.argv[1:]
directory_flags = os.O_RDONLY | os.O_DIRECTORY
directory_flags |= getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)
read_flags = os.O_RDONLY | getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)

def identity(info):
    return f"{info.st_dev}:{info.st_ino}"

def open_project(path):
    normalized = os.path.normpath(path if os.path.isabs(path) else os.path.join(os.getcwd(), path))
    if any(ord(character) < 32 for character in normalized):
        raise RuntimeError("project path contains control characters")
    fd = os.open("/", directory_flags)
    try:
        for component in [part for part in normalized.split("/") if part]:
            next_fd = os.open(component, directory_flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        if identity(os.fstat(fd)) != expected_root:
            raise RuntimeError("project directory identity changed")
        return fd
    except BaseException:
        os.close(fd)
        raise

def open_state_directory(root_fd):
    try:
        os.mkdir(".spacefast", 0o700, dir_fd=root_fd)
    except FileExistsError:
        pass
    fd = os.open(".spacefast", directory_flags, dir_fd=root_fd)
    info = os.fstat(fd)
    if not stat.S_ISDIR(info.st_mode):
        os.close(fd)
        raise RuntimeError(".spacefast must be a real directory")
    os.fchmod(fd, 0o700)
    return fd

def read_regular(directory_fd, name, expected="*", json_object=False):
    try:
        fd = os.open(name, read_flags, dir_fd=directory_fd)
    except FileNotFoundError:
        if expected not in ("*", "missing"):
            raise RuntimeError(f"{name} disappeared")
        return None, "missing"
    try:
        info = os.fstat(fd)
        entry = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
            raise RuntimeError(f"{name} must be a singly linked regular file")
        if (entry.st_dev, entry.st_ino) != (info.st_dev, info.st_ino):
            raise RuntimeError(f"{name} changed while opening")
        actual = identity(info)
        if expected not in ("*", actual):
            raise RuntimeError(f"{name} identity changed")
        chunks = []
        while True:
            chunk = os.read(fd, 65536)
            if not chunk:
                break
            chunks.append(chunk)
            if sum(map(len, chunks)) > 1024 * 1024:
                raise RuntimeError(f"{name} is too large")
        final = os.fstat(fd)
        entry = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if identity(final) != actual or (entry.st_dev, entry.st_ino) != (info.st_dev, info.st_ino):
            raise RuntimeError(f"{name} changed while reading")
        payload = b"".join(chunks)
        if json_object:
            value = json.loads(payload.decode("utf-8"))
            if not isinstance(value, dict):
                raise RuntimeError(f"{name} must contain a JSON object")
            return value, actual
        return payload, actual
    finally:
        os.close(fd)

def missing_matches(directory_fd, name, expected):
    if expected != "missing":
        return
    try:
        os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
    except FileNotFoundError:
        return
    raise RuntimeError(f"{name} appeared after state discovery")

def same_identity(left, right):
    return (left.st_dev, left.st_ino) == (right.st_dev, right.st_ino)

def validate_destination(directory_fd, name, expected):
    if expected == "missing":
        missing_matches(directory_fd, name, expected)
    else:
        read_regular(directory_fd, name, expected)

def atomic_write(directory_fd, name, payload, mode, expected):
    validate_destination(directory_fd, name, expected)
    temp_name = None
    temp_fd = None
    temp_identity = None
    try:
        for _ in range(128):
            candidate = f".{name}.tmp.{secrets.token_hex(16)}"
            try:
                temp_fd = os.open(
                    candidate,
                    os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0),
                    0o600,
                    dir_fd=directory_fd,
                )
                temp_name = candidate
                temp_info = os.fstat(temp_fd)
                temp_identity = (temp_info.st_dev, temp_info.st_ino)
                break
            except FileExistsError:
                continue
        if temp_fd is None or temp_name is None or temp_identity is None:
            raise RuntimeError("could not allocate an exclusive state temp")
        view = memoryview(payload)
        while view:
            written = os.write(temp_fd, view)
            view = view[written:]
        os.fchmod(temp_fd, mode)
        os.fsync(temp_fd)
        temp_info = os.fstat(temp_fd)
        temp_entry = os.stat(temp_name, dir_fd=directory_fd, follow_symlinks=False)
        if temp_info.st_nlink != 1 or not same_identity(temp_info, temp_entry):
            raise RuntimeError("state temp acquired another link or changed identity")
        validate_destination(directory_fd, name, expected)
        os.rename(temp_name, name, src_dir_fd=directory_fd, dst_dir_fd=directory_fd)
        temp_name = None
        destination = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        temp_info = os.fstat(temp_fd)
        if temp_info.st_nlink != 1 or not same_identity(temp_info, destination):
            raise RuntimeError("atomic state replacement lost identity")
        os.fsync(directory_fd)
    finally:
        if temp_name is not None and temp_identity is not None:
            try:
                entry = os.stat(temp_name, dir_fd=directory_fd, follow_symlinks=False)
                if (entry.st_dev, entry.st_ino) == temp_identity:
                    os.unlink(temp_name, dir_fd=directory_fd)
            except FileNotFoundError:
                pass
        if temp_fd is not None:
            os.close(temp_fd)

try:
    root_fd = open_project(project_path)
    try:
        state_dir_fd = open_state_directory(root_fd)
        try:
            if expected_state == "missing":
                missing_matches(state_dir_fd, "state.json", expected_state)
                current_state = None
                current_state_id = "missing"
            else:
                current_state, current_state_id = read_regular(
                    state_dir_fd, "state.json", expected_state, json_object=True
                )
            if expected_link == "missing":
                missing_matches(state_dir_fd, "space.json", expected_link)
                current_link_id = "missing"
            else:
                _, current_link_id = read_regular(
                    state_dir_fd, "space.json", expected_link, json_object=True
                )
            gitignore, gitignore_id = read_regular(root_fd, ".gitignore")

            if operation not in ("replace", "merge", "link", "verify"):
                raise RuntimeError("unknown state operation")
            incoming_bytes = sys.stdin.buffer.read()
            if operation in ("replace", "merge"):
                incoming = json.loads(incoming_bytes.decode("utf-8"))
                if not isinstance(incoming, dict):
                    raise RuntimeError("new state must be a JSON object")
                if operation == "merge":
                    merged = dict(current_state or {})
                    merged.update(incoming)
                else:
                    merged = incoming
                if delete_key:
                    merged.pop(delete_key, None)
                merged["schemaVersion"] = 1
                state_payload = json.dumps(merged, separators=(",", ":"), ensure_ascii=True).encode()
                atomic_write(
                    state_dir_fd, "state.json", state_payload, 0o600, current_state_id
                )
            if space_id:
                link_payload = json.dumps({"space": space_id}, separators=(",", ":")).encode()
                atomic_write(
                    state_dir_fd, "space.json", link_payload, 0o644, current_link_id
                )

            try:
                git_info = os.stat(".git", dir_fd=root_fd, follow_symlinks=False)
                has_git = stat.S_ISDIR(git_info.st_mode)
            except FileNotFoundError:
                has_git = False
            if operation != "verify" and (has_git or gitignore is not None):
                line = b".spacefast/state.json"
                contents = gitignore or b""
                if line not in contents.splitlines():
                    if contents and not contents.endswith(b"\n"):
                        contents += b"\n"
                    atomic_write(
                        root_fd,
                        ".gitignore",
                        contents + line + b"\n",
                        0o644,
                        gitignore_id,
                    )
        finally:
            os.close(state_dir_fd)
    finally:
        os.close(root_fd)
except BaseException as error:
    print(f"error: unsafe_state_path\nhint: {error}", file=sys.stderr)
    raise SystemExit(2)
' "$PROJECT_ROOT" "$STATE_PROJECT_ID" "$STATE_FILE_ID" "$STATE_LINK_ID" \
    "$operation" "$delete_key" "$space_id"
}

curl_form_file_operand() { # <field> <path>
  local field="$1" escaped="$2"
  escaped="${escaped//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  printf '%s=@"%s"' "$field" "$escaped"
}

curl_form_stdin_operand() { # <field> <filename>
  local field="$1" escaped="$2"
  escaped="${escaped//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  printf '%s=@-;filename="%s"' "$field" "$escaped"
}

secure_file_to_stdout() { # <target>
  local secure_python
  secure_python="$(trusted_python)" || return
  "$secure_python" -I -c '
import os, stat, sys

flags = os.O_RDONLY | getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)
directory_flags = flags | os.O_DIRECTORY
path = os.path.normpath(sys.argv[1] if os.path.isabs(sys.argv[1]) else os.path.join(os.getcwd(), sys.argv[1]))
try:
    fd = os.open("/", directory_flags)
    try:
        components = [part for part in path.split("/") if part]
        for component in components[:-1]:
            next_fd = os.open(component, directory_flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        file_fd = os.open(components[-1], flags, dir_fd=fd)
        try:
            info = os.fstat(file_fd)
            entry = os.stat(components[-1], dir_fd=fd, follow_symlinks=False)
            if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
                raise RuntimeError("publish file must be a singly linked regular file")
            if (entry.st_dev, entry.st_ino) != (info.st_dev, info.st_ino):
                raise RuntimeError("publish file changed while opening")
            while True:
                chunk = os.read(file_fd, 65536)
                if not chunk:
                    break
                sys.stdout.buffer.write(chunk)
        finally:
            os.close(file_fd)
    finally:
        os.close(fd)
except BaseException as error:
    print(f"error: unsafe_publish_path\nhint: {error}", file=sys.stderr)
    raise SystemExit(2)
' "$1"
}

secure_archive_to_stdout() { # <target>
  local secure_python
  secure_python="$(trusted_python)" || return
  "$secure_python" -I -c '
import fnmatch, os, stat, sys, zipfile

directory_flags = os.O_RDONLY | os.O_DIRECTORY
directory_flags |= getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)
file_flags = os.O_RDONLY | getattr(os, "O_CLOEXEC", 0) | getattr(os, "O_NOFOLLOW", 0)
excluded_directories = {".git", ".spacefast", ".stattic", ".ssh", ".aws", ".kube", ".docker"}
excluded_files = (
    ".env*", ".npmrc", ".netrc", "credentials.json", "*.pem", "*.key",
    "*.p12", "*.pfx", "*.crt", "*id_rsa*", "*.zip", "*.tar", "*.tgz",
)

def excluded(path):
    parts = path.split("/")
    return any(part in excluded_directories for part in parts[:-1]) or any(
        fnmatch.fnmatchcase(parts[-1], pattern) for pattern in excluded_files
    )

def matching(left, right):
    return (left.st_dev, left.st_ino) == (right.st_dev, right.st_ino)

def walk(archive, directory_fd, prefix=""):
    for name in sorted(os.listdir(directory_fd)):
        archive_name = f"{prefix}/{name}" if prefix else name
        if excluded(archive_name):
            continue
        entry = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if stat.S_ISLNK(entry.st_mode):
            raise RuntimeError(f"symbolic link in publish root: {archive_name}")
        if stat.S_ISDIR(entry.st_mode):
            child_fd = os.open(name, directory_flags, dir_fd=directory_fd)
            try:
                opened = os.fstat(child_fd)
                if not matching(opened, entry):
                    raise RuntimeError(f"directory changed while opening: {archive_name}")
                walk(archive, child_fd, archive_name)
            finally:
                os.close(child_fd)
            continue
        if not stat.S_ISREG(entry.st_mode) or entry.st_nlink != 1:
            raise RuntimeError(f"unsafe publish entry: {archive_name}")
        file_fd = os.open(name, file_flags, dir_fd=directory_fd)
        try:
            opened = os.fstat(file_fd)
            current = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
            if opened.st_nlink != 1 or not matching(opened, entry) or not matching(opened, current):
                raise RuntimeError(f"file changed while opening: {archive_name}")
            info = zipfile.ZipInfo(archive_name)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = (opened.st_mode & 0xFFFF) << 16
            with archive.open(info, "w") as output:
                while True:
                    chunk = os.read(file_fd, 65536)
                    if not chunk:
                        break
                    output.write(chunk)
        finally:
            os.close(file_fd)

path = os.path.normpath(sys.argv[1] if os.path.isabs(sys.argv[1]) else os.path.join(os.getcwd(), sys.argv[1]))
try:
    root_fd = os.open("/", directory_flags)
    try:
        for component in [part for part in path.split("/") if part]:
            next_fd = os.open(component, directory_flags, dir_fd=root_fd)
            os.close(root_fd)
            root_fd = next_fd
        with zipfile.ZipFile(sys.stdout.buffer, "w", allowZip64=True) as archive:
            walk(archive, root_fd)
    finally:
        os.close(root_fd)
except BaseException as error:
    print(f"error: unsafe_publish_path\nhint: {error}", file=sys.stderr)
    raise SystemExit(2)
' "$1"
}

# Build multipart flags that consume bytes from stdin. Sensitive inputs are
# opened and streamed by the no-follow helpers at request time, eliminating the
# check-then-open and named-archive windows.
build_upload() { # <target>
  local target="$1" filename
  case "$target" in -*) target="./$target" ;; esac
  reject_symlink_components "$target" publish || return
  if [ -f "$target" ]; then
    UPLOAD_KIND=file
    filename="${target%/}"
    filename="${filename##*/}"
    UPLOAD_ARGS=(-F "$(curl_form_stdin_operand files "$filename")")
  elif [ -d "$target" ]; then
    UPLOAD_KIND=archive
    UPLOAD_ARGS=(-F 'archive=@-;filename="spacefast-site.zip"')
  else
    printf 'error: not_found\nhint: %s is not a file or directory.\n' "$target" >&2
    return 2
  fi
  UPLOAD_SOURCE="$target"
}

stream_upload() {
  case "$UPLOAD_KIND" in
    file) secure_file_to_stdout "$UPLOAD_SOURCE" ;;
    archive) secure_archive_to_stdout "$UPLOAD_SOURCE" ;;
    *) return 2 ;;
  esac
}

cleanup_upload() {
  return 0
}

# Pull the interesting fields out of a publish receipt. Sets RECEIPT_* vars.
# The space key is extracted but must never be printed.
parse_receipt() { # <body>
  local body="$1" claim_section open_section
  if have_jq; then
    RECEIPT_SPACE_ID="$(printf '%s' "$body" | jq -r '.data.space.id // empty')"
    RECEIPT_LIVE_URL="$(printf '%s' "$body" | jq -r '.data.space.liveUrl // empty')"
    RECEIPT_VERSION_ID="$(printf '%s' "$body" | jq -r '.data.version.id // empty')"
    RECEIPT_VERSION_URL="$(printf '%s' "$body" | jq -r '.data.version.immutableUrl // empty')"
    RECEIPT_OPEN_URL="$(printf '%s' "$body" | jq -r '.data.open.url // empty')"
    RECEIPT_OPEN_EXPIRES="$(printf '%s' "$body" | jq -r '.data.open.expiresAt // empty')"
    RECEIPT_CLAIM_TOKEN="$(printf '%s' "$body" | jq -r '.data.claim.key // empty')"
    RECEIPT_CLAIM_URL="$(printf '%s' "$body" | jq -r '.data.claim.claimUrl // empty')"
    RECEIPT_SITE_URL="$(printf '%s' "$body" | jq -r '.data.claim.url // empty')"
    RECEIPT_CLAIM_EXPIRES="$(printf '%s' "$body" | jq -r '.data.claim.expiresAt // empty')"
    RECEIPT_NEXT_ACTION="$(printf '%s' "$body" | jq -r '.data.next.action // empty')"
    RECEIPT_OPERATION_ID="$(printf '%s' "$body" | jq -r '.data.operation.id // empty')"
  else
    RECEIPT_SPACE_ID="$(printf '%s' "$body" | grep -o '"spc_[A-Za-z0-9]*"' | head -n 1 | tr -d '"')"
    RECEIPT_VERSION_ID="$(printf '%s' "$body" | grep -o '"ver_[A-Za-z0-9]*"' | head -n 1 | tr -d '"')"
    RECEIPT_OPERATION_ID="$(printf '%s' "$body" | grep -o '"op_[A-Za-z0-9]*"' | head -n 1 | tr -d '"' || true)"
    RECEIPT_LIVE_URL="$(json_field liveUrl "$body")"
    RECEIPT_VERSION_URL="$(json_field immutableUrl "$body")"
    RECEIPT_NEXT_ACTION="$(json_field action "$body" || true)"
    open_section="${body#*\"open\"}"
    RECEIPT_OPEN_URL="$(json_field url "$open_section")"
    RECEIPT_OPEN_EXPIRES="$(json_field expiresAt "$open_section")"
    claim_section="${body#*\"claim\"}"
    RECEIPT_CLAIM_TOKEN="$(json_field key "$claim_section")"
    RECEIPT_CLAIM_URL="$(json_field claimUrl "$claim_section")"
    RECEIPT_SITE_URL="$(json_field url "$claim_section")"
    RECEIPT_CLAIM_EXPIRES="$(json_field expiresAt "$claim_section")"
  fi
}

await_publish_receipt() { # <initial-body> <credential-or-empty> <trusted-api-origin>
  local body="$1" credential="$2" api_url="$3" poll_body status attempt
  parse_receipt "$body"
  case "${RECEIPT_NEXT_ACTION:-done}" in
    '' | done) return 0 ;;
    poll) ;;
    *)
      printf 'error: publish_incomplete\nhint: the inline publish returned an unexpected %s continuation.\n' "$RECEIPT_NEXT_ACTION" >&2
      return 1
      ;;
  esac
  validate_operation_id "$RECEIPT_OPERATION_ID" || return
  [ -n "$credential" ] || credential="$RECEIPT_CLAIM_TOKEN"
  if [ -z "$credential" ]; then
    printf 'error: publish_poll_credential_missing\nhint: the publish is still running but its operation cannot be polled without a credential.\n' >&2
    return 1
  fi
  printf 'Publish accepted — waiting for public readiness…\n' >&2
  for ((attempt = 0; attempt < 300; attempt += 1)); do
    poll_body="$(curl_auth "$credential" "$api_url/v1/operations/$RECEIPT_OPERATION_ID")"
    check_envelope "$poll_body" || return
    if have_jq; then
      status="$(printf '%s' "$poll_body" | jq -r '.data.status // empty')"
    else
      status="$(json_field status "$poll_body")"
    fi
    case "$status" in
      succeeded)
        RECEIPT_NEXT_ACTION=done
        return 0
        ;;
      failed | canceled)
        printf 'error: publish_%s\nhint: finalization did not complete; inspect operation %s.\n' "$status" "$RECEIPT_OPERATION_ID" >&2
        return 1
        ;;
      queued | running) sleep 2 ;;
      *)
        printf 'error: invalid_operation_status\nhint: operation %s returned an unknown status.\n' "$RECEIPT_OPERATION_ID" >&2
        return 1
        ;;
    esac
  done
  printf 'error: publish_wait_timeout\nhint: operation %s is still running; inspect it with sf operations.\n' "$RECEIPT_OPERATION_ID" >&2
  return 1
}

report_receipt() {
  [ -n "${RECEIPT_SPACE_ID:-}" ] && printf 'Space: %s\n' "$RECEIPT_SPACE_ID"
  [ -n "${RECEIPT_LIVE_URL:-}" ] && printf 'Live URL: %s\n' "$RECEIPT_LIVE_URL"
  [ -n "${RECEIPT_VERSION_URL:-}" ] && printf 'Version URL: %s\n' "$RECEIPT_VERSION_URL"
  if [ -n "${RECEIPT_OPEN_URL:-}" ]; then
    printf 'Open privately (repeatable until %s): %s\n' \
      "${RECEIPT_OPEN_EXPIRES:-soon}" "$RECEIPT_OPEN_URL"
  elif [ -n "${RECEIPT_SITE_URL:-}" ]; then
    printf 'Open privately (until %s): %s\n' \
      "${RECEIPT_CLAIM_EXPIRES:-soon}" "$RECEIPT_SITE_URL"
  fi
  if [ -n "${RECEIPT_CLAIM_URL:-}" ]; then
    printf 'Claim link (show the user; expires %s): %s\n' \
      "${RECEIPT_CLAIM_EXPIRES:-soon}" "$RECEIPT_CLAIM_URL"
  fi
  return 0
}
