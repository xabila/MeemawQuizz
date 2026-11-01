#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ASC_KEY_ID="T2P452FSM8"
ASC_ISSUER_ID="92e1b925-7e06-4a57-9f7a-143e9e7a2fc0"
ASC_KEY_PATH="$HOME/Downloads/AuthKey_T2P452FSM8.p8"
ARCHIVE_PATH="/tmp/MeemawQuizz.xcarchive"
EXPORT_DIR="/tmp/MeemawQuizzExport"

echo "1/4 Regeneration du projet Xcode via XcodeGen..."
xcodegen generate

echo "2/4 Archive Release de MeemawQuizz (com.xlarrodeapp.meemawquizz)..."
rm -rf "$ARCHIVE_PATH" "$EXPORT_DIR"
xcodebuild archive \
  -project MeemawQuizz.xcodeproj \
  -scheme MeemawQuizz \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"

echo "3/4 Export de l'IPA App Store Connect..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath "$EXPORT_DIR" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"

IPA_FILE="$EXPORT_DIR/MeemawQuizz.ipa"
echo "4/4 Upload vers TestFlight : $IPA_FILE"
xcrun altool --upload-app \
  --type ios \
  --file "$IPA_FILE" \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

echo "✅ MeemawQuizz envoyé sur TestFlight !"
