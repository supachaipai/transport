#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: ไม่พบ Flutter SDK ใน PATH"
  echo "ติดตั้ง Flutter stable ก่อน แล้วรันไฟล์นี้ใหม่"
  exit 1
fi

TMP="$(mktemp -d)"
cp pubspec.yaml "$TMP/pubspec.yaml"
cp analysis_options.yaml "$TMP/analysis_options.yaml"
cp -R lib "$TMP/lib"
cp -R assets "$TMP/assets"
cp -R tool "$TMP/tool"
cp -R docs "$TMP/docs" 2>/dev/null || true
cp README_TH.md "$TMP/README_TH.md" 2>/dev/null || true

flutter create --org com.appkhonsong --project-name appkhonsong --platforms android,ios .

rm -rf lib assets tool docs
cp "$TMP/pubspec.yaml" pubspec.yaml
cp "$TMP/analysis_options.yaml" analysis_options.yaml
cp -R "$TMP/lib" lib
cp -R "$TMP/assets" assets
cp -R "$TMP/tool" tool
cp -R "$TMP/docs" docs 2>/dev/null || true
cp "$TMP/README_TH.md" README_TH.md 2>/dev/null || true
rm -rf "$TMP"

python3 tool/patch_platforms.py
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter analyze

echo
printf '%s\n' "พร้อมแล้ว" "Android: flutter build apk --release" "iPhone: flutter build ipa --release  (ต้องใช้ macOS + Apple Developer signing)"
