#!/bin/bash
set -e

echo "Building ArcWicky for macOS..."

if ! command -v swift &> /dev/null; then
    echo "Error: Swift is not installed or not in PATH"
    echo "Please install Xcode or Xcode Command Line Tools"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.0.0"
if [ -f "$SCRIPT_DIR/VERSION" ]; then
    VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION")"
fi

echo "Running tests..."
swift test

echo "Building release binary..."
swift build -c release --arch arm64

SHOW_BIN="$(swift build -c release --show-bin-path 2>/dev/null || true)"
if [ -n "$SHOW_BIN" ] && [ -d "$SHOW_BIN" ] && [ -f "$SHOW_BIN/ArcWicky" ]; then
    BUILD_DIR="$SHOW_BIN"
elif [ -d "$SCRIPT_DIR/.build/arm64-apple-macosx/release" ] && [ -f "$SCRIPT_DIR/.build/arm64-apple-macosx/release/ArcWicky" ]; then
    BUILD_DIR="$SCRIPT_DIR/.build/arm64-apple-macosx/release"
elif [ -d "$SCRIPT_DIR/.build/out/Products/Release" ] && [ -f "$SCRIPT_DIR/.build/out/Products/Release/ArcWicky" ]; then
    BUILD_DIR="$SCRIPT_DIR/.build/out/Products/Release"
elif [ -n "$SHOW_BIN" ] && [ -d "$SHOW_BIN" ] && [ -f "$SHOW_BIN/Vermut" ]; then
    BUILD_DIR="$SHOW_BIN"
else
    BUILD_DIR="$SCRIPT_DIR/.build/arm64-apple-macosx/release"
fi
APP_NAME="ArcWicky"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

if [ -f "$BUILD_DIR/ArcWicky" ]; then
    cp "$BUILD_DIR/ArcWicky" "$APP_BUNDLE/Contents/MacOS/ArcWicky"
else
    cp "$BUILD_DIR/Vermut" "$APP_BUNDLE/Contents/MacOS/ArcWicky"
fi
ln -sf "ArcWicky" "$APP_BUNDLE/Contents/MacOS/Vermut"

cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ArcWicky</string>
    <key>CFBundleDisplayName</key>
    <string>ArcWicky</string>
    <key>CFBundleIdentifier</key>
    <string>com.opensource.arcwicky</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>ArcWicky</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Oscar Alfredo Pérez Lara. All rights reserved.</string>
    <key>NSLocalNetworkUsageDescription</key>
    <string>Steam uses your local network for downloads from other computers, Remote Play and in-home streaming.</string>
    <key>NSBonjourServices</key>
    <array>
        <string>_arcwicky._tcp</string>
    </array>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>exe</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Windows Executable</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
        </dict>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>msi</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Windows Installer</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
        </dict>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>bat</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Windows Batch File</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
        </dict>
    </array>
</dict>
</plist>
EOF

ICONSET="$SCRIPT_DIR/Resources/AppIcon.iconset"
ICNS_DEST="$APP_BUNDLE/Contents/Resources/AppIcon.icns"
if command -v iconutil >/dev/null 2>&1 && [ -d "$ICONSET" ]; then
    echo "Building AppIcon.icns from Resources/AppIcon.iconset (light-background primary)…"
    iconutil -c icns "$ICONSET" -o "$ICNS_DEST"
elif [ -f "$SCRIPT_DIR/Resources/AppIcon.icns" ]; then
    cp "$SCRIPT_DIR/Resources/AppIcon.icns" "$ICNS_DEST"
elif [ -f "$SCRIPT_DIR/icon.icns" ]; then
    cp "$SCRIPT_DIR/icon.icns" "$ICNS_DEST"
else
    echo "Note: iconutil not found; AppIcon.icns will be generated on macOS builds."
fi

# Copied PNG/PDF glyphs. Asset-catalog SVGs are not compiled by actool in this
# SwiftPM path, so the app loads these files from Bundle.main Resources.
BRAND_SRC="$SCRIPT_DIR/Sources/CaskLauncherCore/BrandAssets"
if [ ! -d "$BRAND_SRC" ]; then
    BRAND_SRC="$SCRIPT_DIR/Resources/BrandAssets"
fi
if [ ! -d "$BRAND_SRC" ]; then
    echo "Error: BrandAssets directory missing (expected Sources/CaskLauncherCore/BrandAssets)"
    exit 1
fi
mkdir -p "$APP_BUNDLE/Contents/Resources/BrandAssets"
cp -R "$BRAND_SRC/." "$APP_BUNDLE/Contents/Resources/BrandAssets/"

if [ -f "$SCRIPT_DIR/Resources/arcwicky_sculpture_clean.html" ]; then
    cp "$SCRIPT_DIR/Resources/arcwicky_sculpture_clean.html" "$APP_BUNDLE/Contents/Resources/"
fi

if [ -d "$SCRIPT_DIR/Resources/showcase" ]; then
    mkdir -p "$APP_BUNDLE/Contents/Resources/showcase"
    cp -R "$SCRIPT_DIR/Resources/showcase/." "$APP_BUNDLE/Contents/Resources/showcase/"
fi

copy_spm_bundle() {
    local name="$1"
    local found
    found=$(find "$BUILD_DIR" -maxdepth 3 -name "$name" | head -n 1)
    if [ -n "$found" ]; then
        cp -R "$found" "$APP_BUNDLE/Contents/Resources/"
        return 0
    fi
    return 1
}

# Try ArcWicky bundles first, fall back to Vermut bundles
copy_spm_bundle "ArcWicky_CaskLauncherApp.bundle" || copy_spm_bundle "Vermut_CaskLauncherApp.bundle" || {
    echo "Error: SwiftPM resource bundle for CaskLauncherApp not found in $BUILD_DIR"
    exit 1
}
copy_spm_bundle "ArcWicky_CaskLauncherCore.bundle" || copy_spm_bundle "Vermut_CaskLauncherCore.bundle" || {
    echo "Error: SwiftPM resource bundle for CaskLauncherCore not found in $BUILD_DIR"
    exit 1
}

REQUIRED_BRAND=(
    steam.png steam@2x.png steam@3x.png steam.pdf
    epic.png epic@2x.png epic@3x.png epic.pdf
    gog.png gog@2x.png gog@3x.png gog.pdf
    vermut-mark.png vermut-mark@2x.png vermut-mark@3x.png
    vermut-wordmark.png vermut-wordmark@2x.png vermut-wordmark@3x.png vermut-wordmark.pdf
    vermut-wordmark-white.png vermut-wordmark-white@2x.png vermut-wordmark-white@3x.png vermut-wordmark-white.pdf
)
missing=0
for f in "${REQUIRED_BRAND[@]}"; do
    if [ ! -s "$APP_BUNDLE/Contents/Resources/BrandAssets/$f" ]; then
        echo "Error: missing or empty $f in ArcWicky.app/Contents/Resources/BrandAssets"
        missing=1
    fi
done
if [ "$missing" -ne 0 ]; then
    echo "Brand asset verification failed."
    exit 1
fi
echo "Brand assets verified in $APP_BUNDLE/Contents/Resources/BrandAssets"

# Ad-hoc sign the fully assembled bundle. The linker's ad-hoc signature does not
# seal resources or bind Info.plist; with a quarantine flag (browser download)
# macOS then reports the app as "damaged". A proper ad-hoc signature gives the
# normal "unidentified developer" Gatekeeper prompt instead.
echo "Signing $APP_BUNDLE (ad-hoc)..."
xattr -cr "$APP_BUNDLE"
codesign --force --deep --sign - --timestamp=none "$APP_BUNDLE"
if ! codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"; then
    echo "Error: codesign verification failed for $APP_BUNDLE"
    exit 1
fi

# The app must not depend on the build machine's .build path (SwiftPM Bundle.module).
if [ "${SKIP_SMOKE_TEST:-0}" != "1" ]; then
    "$SCRIPT_DIR/scripts/smoke-test-app.sh" "$APP_BUNDLE"
fi

# The build output is not an installed app: keep it out of LaunchServices so
# Launchpad/Spotlight only ever show /Applications/ArcWicky.app.
"/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister" -u "$APP_BUNDLE" >/dev/null 2>&1 || true

echo ""
echo "✅ Build complete!"
echo "App bundle created at: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install system-wide:"
echo "  cp -r $APP_BUNDLE /Applications/"
