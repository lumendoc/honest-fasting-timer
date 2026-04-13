# Headless iOS Signing

This repo is set up for fully headless release signing with `fastlane match`.

## Required Secrets

Copy `.env.match.example` to a secure local env file or inject the same variables through your agent runtime:

```bash
MATCH_GIT_URL
MATCH_GIT_BRANCH
MATCH_PASSWORD
MATCH_READONLY
MATCH_KEYCHAIN_NAME
MATCH_KEYCHAIN_PASSWORD
APPSTORECONNECT_KEY_ID
APPSTORECONNECT_ISSUER_ID
APPSTORECONNECT_API_KEY_PATH
```

`APPSTORECONNECT_API_KEY_PATH` may be replaced by:

```bash
APPSTORECONNECT_API_KEY_CONTENT
APPSTORECONNECT_API_KEY_BASE64=1
```

## Match Repo Contract

Use one private signing repo for all apps. This repo expects:

```text
match AppStore com.lumen.honestfastingtimer
match AppStore com.lumen.honestfastingtimer.widget
```

## Bootstrap Once

Install toolchain on the Mac first:

```bash
brew install ruby
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
gem install bundler fastlane
```

Verify:

```bash
ruby -v
bundle -v
fastlane --version
```

Run this once from a machine with working Apple portal access:

```bash
bundle install
bundle exec fastlane match appstore --git_url "$MATCH_GIT_URL" --app_identifier com.lumen.honestfastingtimer
bundle exec fastlane match appstore --git_url "$MATCH_GIT_URL" --app_identifier com.lumen.honestfastingtimer.widget
```

After that, bots should use readonly mode.

## Bot Flow

```bash
cp .env.match.example .env.match
set -a
source .env.match
set +a

./scripts/ios-sync-signing.sh
./scripts/ios-local-archive.sh
./scripts/ios-local-upload.sh
```
