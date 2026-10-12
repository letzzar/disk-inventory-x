#!/bin/bash
# Build a universal (arm64 + x86_64) "Disk Inventory X.app" and a .dmg in dist/.
#
# Needs the TreeMapView framework checked out next to this repository:
#   ../treemapview-framework  (https://gitlab.com/tderlien/treemapview-framework)
#
# Environment:
#   ARCHS     architectures (default: "arm64 x86_64")
#   SIGN_ID   codesign identity (default: "-" = ad-hoc)

set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SRC_DIR/build"
DIST_DIR="$SRC_DIR/dist"
ARCHS="${ARCHS:-arm64 x86_64}"
SIGN_ID="${SIGN_ID:--}"

if [ ! -d "$SRC_DIR/../treemapview-framework/TreeMapView.xcodeproj" ]; then
    echo "TreeMapView framework not found in $SRC_DIR/../treemapview-framework" >&2
    exit 1
fi

xcodebuild -workspace "$SRC_DIR/Disk Inventory X.xcworkspace" -scheme "Disk Inventory X" \
    -configuration Release ARCHS="$ARCHS" ONLY_ACTIVE_ARCH=NO SYMROOT="$BUILD_DIR" \
    CODE_SIGN_IDENTITY="$SIGN_ID" clean build | grep -E "error|warning: [^']*'[^']*' is deprecated|BUILD" | grep -v deprecated || true

APP="$BUILD_DIR/Release/Disk Inventory X.app"
[ -d "$APP" ] || { echo "Build failed" >&2; exit 1; }

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")"
DMG="$DIST_DIR/DiskInventoryX-$VERSION-macos-${ARCHS// /-}.dmg"

lipo -info "$APP/Contents/MacOS/Disk Inventory X"
codesign --verify --deep --strict "$APP"

mkdir -p "$DIST_DIR"
rm -f "$DMG"
STAGING="$(mktemp -d)"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "Disk Inventory X $VERSION" -srcfolder "$STAGING" -ov -format UDZO "$DMG"
rm -rf "$STAGING"

echo "Created $DMG"
