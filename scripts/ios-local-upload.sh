#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IPA_PATH="${1:-$ROOT_DIR/build/export/HonestFastingTimer.ipa}"
KEY_ID="${APPSTORECONNECT_KEY_ID:-7S9SAHVV4Z}"
ISSUER_ID="${APPSTORECONNECT_ISSUER_ID:-2eb29bd9-aa20-47a0-bfb7-c62cee29a08d}"
API_KEY_PATH="${APPSTORECONNECT_API_KEY_PATH:-}"
TRANSPORTER_KEYS_DIR="${HOME}/.appstoreconnect/private_keys"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [[ ! -f "$IPA_PATH" ]]; then
  echo "IPA not found: $IPA_PATH"
  exit 1
fi

cleanup() {
  [[ -n "${TEMP_KEY_PATH:-}" && -f "$TEMP_KEY_PATH" ]] && rm -f "$TEMP_KEY_PATH"
}
trap cleanup EXIT

if [[ -n "$API_KEY_PATH" ]]; then
  if [[ ! -f "$API_KEY_PATH" ]]; then
    echo "App Store Connect API key not found: $API_KEY_PATH"
    exit 1
  fi

  mkdir -p "$TRANSPORTER_KEYS_DIR"
  TEMP_KEY_PATH="$TRANSPORTER_KEYS_DIR/AuthKey_${KEY_ID}.p8"
  cp "$API_KEY_PATH" "$TEMP_KEY_PATH"
fi

xcrun iTMSTransporter \
  -m upload \
  -assetFile "$IPA_PATH" \
  -apiKey "$KEY_ID" \
  -apiIssuer "$ISSUER_ID"
