#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IPA_PATH="${1:-$ROOT_DIR/build/export/HonestFastingTimer.ipa}"
KEY_ID="${APPSTORECONNECT_KEY_ID:-75K95MJRGV}"
ISSUER_ID="${APPSTORECONNECT_ISSUER_ID:-2eb29bd9-aa20-47a0-bfb7-c62cee29a08d}"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [[ ! -f "$IPA_PATH" ]]; then
  echo "IPA not found: $IPA_PATH"
  exit 1
fi

xcrun iTMSTransporter \
  -m upload \
  -assetFile "$IPA_PATH" \
  -apiKey "$KEY_ID" \
  -apiIssuer "$ISSUER_ID"
