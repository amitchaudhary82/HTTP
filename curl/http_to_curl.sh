#!/usr/bin/env bash
# =============================================================================
# http_to_curl.sh - send a Message file (messages/Exxx_...http) with curl
# =============================================================================
#
# The Message files are the golden source. This helper reads one file and
# builds the curl command from it, so nothing is copied by hand:
#
#   request line  GET /path HTTP/1.1  ->  curl -X GET  <base URL>/path
#   headers       Name: value         ->  -H "Name: value"
#   body          after the empty line ->  --data-binary @<temp file>
#
# The base URL comes from the file name suffix and the Host: line:
#   _local     http://127.0.0.1:8080
#   _internet  http://<Host>        (httpbin.org if the file has no Host)
#   _https     https://<Host>
#
# What curl does differently from a raw carrier (that's the lesson):
#   - Host and Content-Length are NOT copied: curl sets them itself.
#     So the wrong-length experiments (E503 - E506) arrive corrected.
#   - A file with two requests (E414) sends only the first one.
#
# HOW TO USE (from the repository root)
#   source curl/http_to_curl.sh
#   http_to_curl messages/E301_get_root_200_local.http
#   http_to_curl messages/E302_get_foldernoSlash_301_local.http -L   # extra curl options
#   HTTP_TO_CURL_DRY=1 http_to_curl messages/E501_...http            # only print the command
# =============================================================================

http_to_curl() {
  local file="$1"; shift
  if [ ! -f "${file}" ]; then
    echo "No such Message file: ${file}" >&2
    return 1
  fi

  # --- request line: METHOD TARGET VERSION
  local first method target
  IFS= read -r first < "${file}"
  first="${first%$'\r'}"
  method="${first%% *}"
  target="${first#* }"
  target="${target% *}"

  # --- Host header (case-insensitive), used for the base URL
  local host
  host="$(grep -i -m1 '^Host:' "${file}" | sed 's/^[Hh][Oo][Ss][Tt]:[ ]*//; s/\r$//')"

  local base
  case "${file}" in
    *_local.http)    base="http://127.0.0.1:8080" ;;
    *_internet.http) base="http://${host:-httpbin.org}" ;;
    *_https.http)    base="https://${host:-httpbin.org}" ;;
    *) echo "Unknown suffix (expected _local, _internet, _https): ${file}" >&2; return 1 ;;
  esac

  # --- headers: lines after the request line, until the first empty line
  # HEAD: curl -X HEAD would wait for a body that never comes; -I is the
  # proper HEAD request in curl
  local args
  if [ "${method}" = "HEAD" ]; then args=(-I); else args=(-X "${method}"); fi
  local line name in_headers=1 n=0
  while IFS= read -r line || [ -n "${line}" ]; do
    n=$((n + 1))
    [ "${n}" -eq 1 ] && continue            # skip the request line
    line="${line%$'\r'}"
    if [ -z "${line}" ]; then break; fi     # empty line = end of headers
    name="$(echo "${line%%:*}" | tr 'A-Z' 'a-z')"
    case "${name}" in
      host|content-length) ;;               # curl sets these itself
      *) args+=(-H "${line}") ;;
    esac
  done < "${file}"

  # --- body: everything after the first empty line, without adding a newline
  local body_file
  body_file="$(mktemp)"
  awk 'f { printf "%s%s", sep, $0; sep = "\n" } !f && /^\r?$/ { f = 1 }' "${file}" > "${body_file}"
  if head -n 1 "${body_file}" | grep -Eq '^[A-Z]+ [^ ]+ HTTP/'; then
    echo "Note: ${file} holds more than one request; curl sends only the first." >&2
    : > "${body_file}"
  fi
  if [ -s "${body_file}" ]; then
    args+=(--data-binary "@${body_file}")
  fi

  if [ -n "${HTTP_TO_CURL_DRY}" ]; then
    echo curl -v "${args[@]}" "$@" "${base}${target}"
  else
    curl -v "${args[@]}" "$@" "${base}${target}"
  fi
  rm -f "${body_file}"
}
