#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-appwrite.mymangatheque.com}"
PROJECT_ID="${2:-69a59d8c003140f373d3}"
CALLBACK_SCHEME="appwrite-callback-${PROJECT_ID}"
SUCCESS="${CALLBACK_SCHEME}://oauth2success"
FAILURE="${CALLBACK_SCHEME}://oauth2failure"

TMP_HEADERS="$(mktemp)"
trap 'rm -f "${TMP_HEADERS}"' EXIT

curl -sS -D "${TMP_HEADERS}" -o /dev/null --get "https://${DOMAIN}/v1/account/tokens/oauth2/google" \
  --data-urlencode "project=${PROJECT_ID}" \
  --data-urlencode "success=${SUCCESS}" \
  --data-urlencode "failure=${FAILURE}"

LOCATION="$(awk 'tolower($1)=="location:"{$1=""; sub(/^ /,""); gsub(/\r/,""); print; exit}' "${TMP_HEADERS}")"
FALLBACK_HEADER="$(awk 'tolower($1)=="x-debug-fallback:"{$1=""; sub(/^ /,""); gsub(/\r/,""); print; exit}' "${TMP_HEADERS}")"

echo "Domain: ${DOMAIN}"
echo "Project: ${PROJECT_ID}"
echo "x-debug-fallback: ${FALLBACK_HEADER:-<absent>}"
echo "Location: ${LOCATION:-<absent>}"

if [[ -z "${LOCATION}" ]]; then
  echo
  echo "ERROR: missing Location header."
  exit 2
fi

if [[ "${LOCATION}" == *"redirect_uri=http%3A%2F%2F${DOMAIN}%2Fv1%2Faccount%2Fsessions%2Foauth2%2Fcallback%2Fgoogle%2F${PROJECT_ID}"* ]]; then
  echo
  echo "FAIL: redirect_uri is HTTP. OAuth Google will fail with redirect_uri_mismatch."
  exit 1
fi

if [[ "${LOCATION}" == *"redirect_uri=https%3A%2F%2F${DOMAIN}%2Fv1%2Faccount%2Fsessions%2Foauth2%2Fcallback%2Fgoogle%2F${PROJECT_ID}"* ]]; then
  echo
  echo "OK: redirect_uri is HTTPS."
  exit 0
fi

echo
echo "WARN: redirect_uri found but pattern does not match expected callback. Inspect Location manually."
exit 3
