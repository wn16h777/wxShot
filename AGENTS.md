# wxShot

Menu-bar-less macOS screenshot tool that replaces WeChat's screenshot when WeChat is not signed in. Pure AppKit, SwiftPM, no third-party code except the
vendored PermissionFlow.

## Build and verify
- `swift build` / `swift test` for development. `scripts/build.sh` builds `dist/wxShot.app` (ad-hoc signed).
- Single test: `swift test --filter LogicTests/testWeChatOwnership` (tests are pure-logic only; nothing needs Screen Recording).
- Release: `scripts/build.sh --universal --sign "Developer ID Application: …" --dmg --notarize` (keychain profile `MY_NTFSTOOL`).
- Mac App Store: `scripts/build.sh --mas …` (sandboxed, `MAS` compile flag removes self-update).
- Debug-only: `WXSHOT_DEBUG_CAPTURE=1 .build/debug/wxShot` opens the capture overlay at launch.
- Debug-only: `WXSHOT_SNAPSHOT=<dir> [WXSHOT_LANG=zh|en|…] .build/debug/wxShot` renders the real settings/onboarding/toolbar windows to PNG, then quits.

## Architecture
- No Xcode project: SwiftPM builds the executable; `scripts/build.sh` hand-assembles the `.app` from the binary, `Sources/wxShot/App/Info.plist` (the real bundle metadata — the app's own version is bumped there, in `CFBundleShortVersionString`), the `Resources/*.lproj` folders, and PermissionFlow's generated resource bundle. Copying that bundle is mandatory: its permission panel crashes at first show without `Bundle.module`.
- `App/main.swift` runs a plain AppKit loop (Info.plist sets `LSUIElement`: no Dock icon) and first installs a minimal Edit menu — AppKit text fields need it for ⌘C/⌘V/⌘A even though no menu is ever visible. `AppDelegate` then enforces single instance (a second launch terminates itself) and maps "app opened again" to "open Settings".
- The product premise lives in `Coexistence/WeChatMonitor.swift`: workspace notifications plus CGWindowList window geometry (no extra permissions, no polling) classify WeChat as `notRunning` / `loginScreen` / `loggedIn`. `AppDelegate.applyHotkeyState()` re-runs on every `.hotkeyDidChange` / `.weChatStateDidChange` and registers the ⌃⌘A hotkey in `Trigger/HotkeyManager.swift` only while `WeChatMonitor.shouldOwnShortcut()` is true.
- Capture is one session at a time: `AppDelegate.overlayController` is the only slot, and the hotkey is ignored while it is occupied. Hotkey → `startCapture` → `Capture/OverlayWindowController.swift` (~2000 lines; the state machine for the freeze-frame overlay, `SelectionView` region selection, magnifier, window detection) → `Capture/ImageEditLauncher.swift` → the editor. Suspending the editor parks a `SuspendedEditDraft`; pressing the shortcut again resumes it instead of starting over. On completion the image goes to the clipboard via `ImageOutputEncoder` + `ClipboardManager` and the slot clears.
- Every other image source — full-screen capture, quick pin, clipboard image, Finder file, re-editing a pin — funnels through `ImageEditLauncher` into `OverlayWindowController(presetImage:)`, so there is exactly one editor path.
- The editor (`Editor/EditWindowController.swift` + `EditCanvasView.swift`, the two biggest files) is WeChat's toolbar rebuilt: `Editor/ToolbarLayout.default` defines tool order, `ToolbarIcons.swift` hand-draws the icons, `ToolbarView.groupEnds` draws the separators.
- Feature offshoots off that spine: `Capture/PinLauncher.swift` (pinned images). This fork removed upstream's long screenshot (`ScrollCapturer`/`AutoScroller`), OCR (`OCR/`) and translate — do not reintroduce them.
- This fork makes **zero network requests**: upstream's `Telemetry/SurvivalReporter.swift` and `Utilities/UpdateChecker.swift` (plus the website/GitHub/feedback UI) were removed. Do not reintroduce network access.
- Localization source of truth is the `S` dictionary in `scripts/add_strings.py`: add the key with both translations there, run `python3 scripts/add_strings.py` (idempotent) to sync `Resources/*.lproj/Localizable.strings`, then add the accessor in `Utilities/L10n+wxShot.swift`.

## Product rules
- Free, no upload code, **no network access at all** — this fork stripped upstream's survival telemetry, update check and feedback/website links. Nothing may talk to the network.
- Default shortcut ⌃⌘A (WeChat for Mac's own screenshot key, so handover is seamless). Coexistence is single-mode and hardcoded in `WeChatMonitor.shouldOwnShortcut()`: WeChat signed in → WeChat owns the key; otherwise wxShot does. The upstream policy picker (auto/alwaysUs/yieldWhenRunning) was removed.
- Only Screen Recording permission is required. Do not add Accessibility or Input Monitoring requirements.
- New user-facing strings go through `scripts/add_strings.py` (2 languages: en + zh-Hans) and `Utilities/L10n+wxShot.swift`.
- The editor toolbar in `ToolbarLayout.default` is this fork's trimmed bar: rectangle, ellipse, arrow, pen, mosaic, text | undo, save, pin, share, close, confirm, plus a ··· more menu and a settings gear at the far right (icons are hand-drawn in `Editor/ToolbarIcons.swift`; `ToolbarView.groupEnds` draws the separators). Emoji was removed along with OCR/translate/long-screenshot — do not reintroduce.
- Share uses the system share sheet.
- Maintenance budget is tiny: do not add features. Only fix macOS compatibility breaks.
