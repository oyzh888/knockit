#!/bin/bash
# Knockit - Build & Run on Steve's iPhone 15 Pro Max
set -e

DEVICE_XCODE_ID="00008130-000A4D2E0162001C"
DEVICE_CORE_ID="23DABC3D-B1D0-5E19-B379-1F778C7879B3"
BUNDLE_ID="com.knock.reminder"
PROJECT="Knock.xcodeproj"
SCHEME="Knock"
APP_PATH="$(xcodebuild -project $PROJECT -scheme $SCHEME -showBuildSettings -destination "platform=iOS,id=$DEVICE_XCODE_ID" 2>/dev/null | grep '^\s*BUILT_PRODUCTS_DIR' | awk '{print $3}')/Knock.app"

echo "🔨 Building..."
xcodebuild -project $PROJECT -scheme $SCHEME \
  -destination "platform=iOS,id=$DEVICE_XCODE_ID" \
  -allowProvisioningUpdates \
  build 2>&1 | grep -E "^(.*error:|.*BUILD |✓)" || true

echo "📲 Installing to iPhone..."
xcrun devicectl device install app --device $DEVICE_CORE_ID "$APP_PATH"

echo "🚀 Launching..."
xcrun devicectl device process launch --device $DEVICE_CORE_ID $BUNDLE_ID

echo "✅ Done!"
