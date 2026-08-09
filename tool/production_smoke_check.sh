#!/usr/bin/env bash

set -euo pipefail

WEB_BASE_URL="${WEB_BASE_URL:-https://mymangatheque.com}"
API_BASE_URL="${API_BASE_URL:-https://api.mymangatheque.com}"
EXPECTED_ORIGIN="${EXPECTED_ORIGIN:-${WEB_BASE_URL}}"

web_headers="$(mktemp)"
web_body="$(mktemp)"
api_headers="$(mktemp)"
trap 'rm -f "${web_headers}" "${web_body}" "${api_headers}"' EXIT

fail_check() {
  echo "Production smoke check failed: $1" >&2
  exit 1
}

require_text() {
  local expected="$1"
  local file="$2"
  local description="$3"

  grep --quiet --ignore-case --fixed-strings "${expected}" "${file}" || \
    fail_check "${description}"
}

curl --fail-with-body --silent --show-error --max-time 20 \
  --dump-header "${web_headers}" \
  --output "${web_body}" \
  "${WEB_BASE_URL%/}/"

require_text 'content-security-policy:' "${web_headers}" \
  'the Web response is missing Content-Security-Policy'
require_text 'cross-origin-opener-policy:' "${web_headers}" \
  'the Web response is missing Cross-Origin-Opener-Policy'
require_text 'flutter_bootstrap.js' "${web_body}" \
  'the Web shell does not reference flutter_bootstrap.js'

curl --fail-with-body --silent --show-error --max-time 20 \
  --output /dev/null \
  "${WEB_BASE_URL%/}/flutter_bootstrap.js"
curl --fail-with-body --silent --show-error --max-time 20 \
  --output /dev/null \
  "${WEB_BASE_URL%/}/main.dart.wasm"

curl --fail-with-body --silent --show-error --max-time 20 \
  --output /dev/null \
  "${API_BASE_URL%/}/healthz"

curl --fail-with-body --silent --show-error --max-time 20 \
  --request OPTIONS \
  --header "Origin: ${EXPECTED_ORIGIN}" \
  --header 'Access-Control-Request-Method: POST' \
  --header 'Access-Control-Request-Headers: authorization,content-type' \
  --dump-header "${api_headers}" \
  --output /dev/null \
  "${API_BASE_URL%/}/api/auth/keys/mobile"

require_text "access-control-allow-origin: ${EXPECTED_ORIGIN}" "${api_headers}" \
  "the API CORS preflight does not allow ${EXPECTED_ORIGIN}"

echo "Production Web, Wasm, API, security headers, and CORS checks passed."
