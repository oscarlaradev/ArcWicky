#!/usr/bin/env bash
# ArcWicky installer.
#   curl -fsSL https://raw.githubusercontent.com/oscarlaradev/ArcWicky/main/install.sh | bash
# Files downloaded with curl are not quarantined, so Gatekeeper does not block the app.
set -euo pipefail

REPO="oscarlaradev/ArcWicky"
APP_NAME="ArcWicky.app"
DEST="/Applications/${APP_NAME}"

say() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "ArcWicky runs on macOS only."
[[ "$(uname -m)" == "arm64" ]] || die "ArcWicky needs a Mac with Apple Silicon (arm64)."
command -v curl >/dev/null 2>&1 || die "curl is required."
command -v hdiutil >/dev/null 2>&1 || die "hdiutil is required."

WORK="$(mktemp -d "${TMPDIR:-/tmp}/arcwicky-install.XXXXXX")"
MOUNT=""
cleanup() {
    if [[ -n "$MOUNT" ]]; then
        hdiutil detach "$MOUNT" -quiet >/dev/null 2>&1 || hdiutil detach "$MOUNT" -force -quiet >/dev/null 2>&1 || true
    fi
    rm -rf "$WORK"
}
trap cleanup EXIT

say "Finding the latest ArcWicky release"
URL=""
if JSON="$(curl -fsSL -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null)"; then
    URL="$(printf '%s\n' "$JSON" | grep -o '"browser_download_url"[[:space:]]*:[[:space:]]*"[^"]*\.dmg"' | head -n 1 | sed -E 's/.*"(https:[^"]*)"$/\1/' || true)"
fi
if [[ -z "$URL" ]]; then
    TAG="$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest" 2>/dev/null | sed -E 's#.*/tag/##' || true)"
    [[ -n "$TAG" && "$TAG" != http* ]] || die "Could not find the latest release."
    URL="https://github.com/${REPO}/releases/latest/download/ArcWicky-${TAG#v}.dmg"
fi

DMG="$WORK/ArcWicky.dmg"
say "Downloading ${URL##*/}"
curl -fL --progress-bar -o "$DMG" "$URL" || die "Download failed: $URL"

say "Opening the disk image"
MOUNT="$(hdiutil attach -nobrowse -readonly -noautoopen "$DMG" | awk -F'\t' '/\/Volumes\//{print $NF; exit}')"
[[ -n "$MOUNT" && -d "$MOUNT/$APP_NAME" ]] || die "ArcWicky.app not found in the disk image."

if pgrep -xq ArcWicky; then
    say "Quitting the running ArcWicky"
    osascript -e 'tell application "ArcWicky" to quit' >/dev/null 2>&1 || true
    for _ in $(seq 1 20); do
        pgrep -xq ArcWicky || break
        sleep 0.5
    done
    pgrep -xq ArcWicky && die "ArcWicky is still running. Quit it and run the installer again."
fi

SUDO=""
if [[ -e "$DEST" && ! -w "$DEST" ]] || [[ ! -w "/Applications" ]]; then
    say "Administrator password needed to write to /Applications"
    SUDO="sudo"
fi

say "Installing to $DEST"
$SUDO rm -rf "$DEST"
$SUDO ditto "$MOUNT/$APP_NAME" "$DEST"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST" >/dev/null 2>&1 || true
$SUDO xattr -dr com.apple.quarantine "$DEST" >/dev/null 2>&1 || true

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$DEST/Contents/Info.plist" 2>/dev/null || echo "")"
printf '\nVermut %s is installed in /Applications. Pour. Click. Play.\n' "$VERSION"

if [[ "${VERMUT_NO_OPEN:-0}" != "1" ]]; then
    open "$DEST" || true
fi
