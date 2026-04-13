# Honest Fasting Timer Local iOS Release Runbook

This app ships from the local Mac only.

Do not use:

- `EAS Build`
- `EAS Submit`

## Project

- Repo: `/Users/bot/workspace/repos/honest-fasting-timer`
- Xcode project: `HonestFastingTimer.xcodeproj`
- Scheme: `HonestFastingTimer`
- Bundle ID: `com.lumen.honestfastingtimer`
- Widget bundle ID: `com.lumen.honestfastingtimer.widget`
- Export options: `ExportOptions-AppStore.plist`
- Version script: `scripts/ios-release-version.js`
- Archive script: `scripts/ios-local-archive.sh`
- Upload script: `scripts/ios-local-upload.sh`

## Required Local Setup

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -version
xcrun iTMSTransporter -m provider
```

## Versioning

### Bump Build

```bash
node scripts/ios-release-version.js --bump-build
```

### Set Version And Build

```bash
node scripts/ios-release-version.js --version 1.0.1 --build 2
```

### Dry Run

```bash
node scripts/ios-release-version.js --version 1.0.1 --bump-build --dry-run
```

This updates both:

- `project.yml`
- `HonestFastingTimer.xcodeproj/project.pbxproj`

## Release Steps

### 1. Confirm Clean Working Tree

```bash
git status --short
```

### 2. Increment Build Or Version

```bash
node scripts/ios-release-version.js --bump-build
```

### 3. Archive And Export IPA

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
./scripts/ios-local-archive.sh
```

### 4. Upload IPA

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
APPSTORECONNECT_KEY_ID=75K95MJRGV \
APPSTORECONNECT_ISSUER_ID=2eb29bd9-aa20-47a0-bfb7-c62cee29a08d \
./scripts/ios-local-upload.sh
```

## Verify

1. Confirm `build/export/HonestFastingTimer.ipa` exists.
2. Open App Store Connect -> TestFlight.
3. Confirm the new build number appears and finishes processing.

## Known Signing Risk

This repo now points at Apple team `AMJGQSTR94` in both `project.yml` and the generated Xcode project.
Archive/upload still depends on Xcode successfully creating or downloading signing assets for both the app target and the widget target.

## Recovery

### Archive Fails With Signing Errors

Fix in Xcode:

1. Open `HonestFastingTimer.xcodeproj`
2. Set the Apple team for:
   - `HonestFastingTimer`
   - `HonestFastingTimerWidgetExtension`
3. Keep signing automatic unless manual signing is required
4. Retry the archive script

If the Xcode project is regenerated from `project.yml`, keep `DEVELOPMENT_TEAM` updated there too.

### Upload Fails

Check:

- `xcrun iTMSTransporter` works under `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- the `.ipa` exists
- App Store Connect upload key is still valid

### Version Drift

Only use `scripts/ios-release-version.js` for release version/build changes.
