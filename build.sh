#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "→ Building release binary..."
swift build -c release

APP="TextSnap.app"
BIN=".build/release/TextSnap"

if [ ! -f "$BIN" ]; then
    echo "✗ Build output not found at $BIN" >&2
    exit 1
fi

# Skip repackage if the binary is byte-identical to what's already in the bundle.
# This keeps the .app's cdhash stable across no-op rebuilds so TCC (Screen
# Recording permission) doesn't have to be re-granted.
if [ -f "$APP/Contents/MacOS/TextSnap" ] && cmp -s "$BIN" "$APP/Contents/MacOS/TextSnap"; then
    echo "✓ No changes — $APP is already up to date"
    exit 0
fi

echo "→ Packaging $APP..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/TextSnap"
cp Resources/Info.plist "$APP/Contents/Info.plist"

# Ad-hoc sign so Gatekeeper / TCC treats it as a stable identity.
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

echo "✓ Built $(pwd)/$APP"
echo
echo "First-run setup (only needed once):"
echo "  1. open $APP"
echo "  2. Try a capture → click 'Open Privacy Settings' in the dialog"
echo "  3. Toggle TextSnap ON in Privacy & Security → Screen Recording"
echo "  4. Quit TextSnap and reopen (menu bar icon → Quit)"
echo
echo "Tip: move TextSnap.app to /Applications so its location stays stable."
