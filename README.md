# wxShot (personal fork)

Menu-bar-less macOS screenshot tool that replaces WeChat's screenshot when WeChat is not signed in. Press `⌃⌘A` anywhere (WeChat for Mac's own screenshot key); drag to select; double-click or press Return to copy. Rectangle, ellipse, arrow, pen, mosaic, text, pin — WeChat's toolbar, rebuilt in pure AppKit.

This is a **personal fork**: upstream's network-facing pieces (telemetry, update check, website/GitHub/feedback links) and the OCR / translate / long-screenshot features were removed — the app makes **zero network requests** and captures via ScreenCaptureKit entirely on-device.

Forked from [ntfstool/wxShot](https://github.com/ntfstool/wxShot) (MIT). Original copyright and license retained in `LICENSE`.

## Requirements

macOS 14+, Screen Recording permission (the only permission it asks for).

## Build

```bash
swift build && swift test   # development
scripts/build.sh            # dist/wxShot.app (ad-hoc signed)
```

Full Xcode is required — Command Line Tools alone cannot build the vendored PermissionFlow (SwiftUI macros).
