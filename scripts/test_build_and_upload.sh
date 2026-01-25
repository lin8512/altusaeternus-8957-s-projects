#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="com.aeternusaltus.app"
SUPPLY_JSON_KEY_PATH="/tmp/play-service-account.json"
AAB_GLOB="build/app/outputs/bundle/release/*.aab"

echo "1) Ensure Flutter deps and build AAB..."
flutter pub get
flutter clean
flutter build appbundle --release

AAB_COUNT=$(ls $AAB_GLOB 2>/dev/null | wc -l || true)
if [ "$AAB_COUNT" -eq 0 ]; then
    echo "Error: no AAB found at build/app/outputs/bundle/release/"
    exit 1
fi

echo "2) Prepare fastlane environment and run lane"
cd fastlane || (mkdir -p fastlane && cd fastlane)

if [ -f ../Gemfile ]; then
    echo "Using bundler to run fastlane..."
    bundle install --path vendor/bundle || true
    bundle exec fastlane android upload_to_play
else
    fastlane android upload_to_play
fi
