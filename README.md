# TextSnap

A tiny macOS menu bar app that lets you **drag-select an area of the screen** and **extract the text** inside it. Result is shown in a window and copied to the clipboard.

- Uses Apple's **Vision** framework for OCR.
- **Automatic language detection** — works with every script Vision supports (English, Vietnamese, Chinese, Japanese, Korean, Arabic, Cyrillic, Thai, etc.).
- No network, no third-party services, runs fully local.

## Build & run

```bash
cd TextSnap
./build.sh
open TextSnap.app
```

Look for the `􀊫` text-viewfinder icon in your menu bar.

## Use

- **⌘⇧2** anywhere — drag to select an area.
- Or click the menu bar icon → *Capture & Recognize Text*.
- Press **Esc** during selection to cancel.
- Recognized text opens in a window and is auto-copied to the clipboard.

## Files

```
TextSnap/
├── Package.swift
├── build.sh              # builds + bundles into TextSnap.app
├── Resources/Info.plist
└── Sources/TextSnap/
    ├── main.swift
    ├── AppDelegate.swift   # menu bar, hotkey, capture orchestration
    ├── Capture.swift       # area selection via /usr/sbin/screencapture
    ├── OCR.swift           # Vision text recognition
    ├── HotKey.swift        # ⌘⇧2 global hotkey (Carbon)
    └── ResultWindow.swift  # result viewer
```

## Notes

- Requires macOS 13+ (uses `automaticallyDetectsLanguage`).
- Built ad-hoc signed — Gatekeeper will prompt the first time you open it. Right-click → *Open* if needed.
- No Screen Recording permission required: Apple's `screencapture` CLI is user-initiated.
