#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh <version>   e.g. ./release.sh v0.1.0" >&2
    exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "✗ gh CLI not found. Install via: brew install gh" >&2
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "✗ Working tree has uncommitted changes. Commit or stash first." >&2
    git status --short
    exit 1
fi

if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "✗ Tag $VERSION already exists. Pick a new version." >&2
    exit 1
fi

echo "→ Building release..."
./build.sh

ZIP="TextSnap-${VERSION}.zip"
rm -f "$ZIP"
echo "→ Zipping $ZIP..."
ditto -c -k --sequesterRsrc --keepParent TextSnap.app "$ZIP"

echo "→ Tagging $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

echo "→ Creating GitHub release..."
NOTES_FILE="$(mktemp)"
cat > "$NOTES_FILE" <<EOF
## Install

1. Download \`TextSnap-${VERSION}.zip\`, unzip it.
2. Move \`TextSnap.app\` to \`/Applications\`.
3. **Right-click → Open** the first time (Gatekeeper warning is expected for ad-hoc signed apps; click *Open*).
4. If macOS still blocks it, run once in Terminal:
   \`\`\`
   xattr -dr com.apple.quarantine /Applications/TextSnap.app
   \`\`\`
5. Grant **Screen Recording** in *System Settings → Privacy & Security → Screen Recording*, then quit and reopen TextSnap.

## Use

- Press **⌘⇧2** anywhere — drag to select an area.
- Or click the menu bar icon → *Capture & Recognize Text*.
- Recognized text appears in a window and is auto-copied to the clipboard.
- Open *Settings…* from the menu bar to toggle auto-copy, result window, and shutter sound.

Supports every language Apple Vision OCR supports (English, Vietnamese, Chinese, Japanese, Korean, Arabic, Cyrillic, Thai, and more).
EOF

gh release create "$VERSION" "$ZIP" \
    --title "TextSnap $VERSION" \
    --notes-file "$NOTES_FILE"

rm -f "$NOTES_FILE"

echo
echo "✓ Released $VERSION"
gh release view "$VERSION" --web >/dev/null 2>&1 || true
