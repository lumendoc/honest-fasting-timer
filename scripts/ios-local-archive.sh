#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE_PATH="${1:-$ROOT_DIR/build/HonestFastingTimer.xcarchive}"
EXPORT_PATH="${2:-$ROOT_DIR/build/export}"
PROJECT_PATH="$ROOT_DIR/HonestFastingTimer.xcodeproj"
SCHEME="HonestFastingTimer"
EXPORT_OPTIONS_PLIST="$ROOT_DIR/ExportOptions-AppStore.plist"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

xcodebuild -version >/dev/null

rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  clean archive

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

echo "Archive ready: $ARCHIVE_PATH"
echo "IPA ready: $EXPORT_PATH/$SCHEME.ipa"
