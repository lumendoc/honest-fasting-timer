#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export FASTLANE_SKIP_UPDATE_CHECK=1
export FASTLANE_DISABLE_COLORS=1
export PATH="/opt/homebrew/lib/ruby/gems/4.0.0/bin:/opt/homebrew/opt/ruby/bin:$PATH"

cd "$ROOT_DIR"

bundle check >/dev/null 2>&1 || bundle install
bundle exec fastlane ios sync_signing
