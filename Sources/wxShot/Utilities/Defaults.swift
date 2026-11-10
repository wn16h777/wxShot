import Foundation

/// A language the app's UI can be displayed in. Raw values double as the
/// `appLanguage` UserDefaults value (kept stable for backward compatibility).
enum AppLanguage: String, CaseIterable {
    case zh
    case en

    /// Folder name (without extension) of the matching `.lproj` bundle inside
    /// `wxshot.app/Contents/Resources/`.
    var lprojName: String {
        switch self {
        case .zh: return "zh-Hans"
        default:  return rawValue
        }
    }

    /// Native language name shown in the in-app language picker.
    var displayName: String {
        switch self {
        case .zh: return "简体中文"
        case .en: return "English"
        }
    }

    /// Best-effort match of the system's preferred languages to a supported
    /// app language — used on first launch before the user picks explicitly.
    static var systemDefault: AppLanguage {
        for code in Locale.preferredLanguages {
            let lower = code.lowercased()
            if lower.hasPrefix("zh") { return .zh }
            if lower.hasPrefix("en") { return .en }
        }
        return .en
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("wxshot.languageDidChange")
    static let hotkeyDidChange = Notification.Name("wxshot.hotkeyDidChange")
}

/// Centralized accessor for every user-facing string. Each property resolves a
/// key from the current language's `Localizable.strings`; the translations
/// themselves live in `Resources/<lang>.lproj/Localizable.strings`.
enum L10n {
    static var lang: AppLanguage { Defaults.language }

    private static func s(_ key: String) -> String { Localizer.string(key) }

    // Settings
    static var showMenuBarIcon: String { s("showMenuBarIcon") }
    static var permissionsHeader: String { s("permissionsHeader") }
    static var accessibilityDescription: String { s("accessibilityDescription") }
    static var launchAtLogin: String { s("launchAtLogin") }
    static var pinAcrossSpaces: String { s("pinAcrossSpaces") }
    static var screenshotQualityOriginal: String { s("screenshotQualityOriginal") }
    static var screenshotQualityOriginalHint: String { s("screenshotQualityOriginalHint") }
    static var screenshotQualityCompressed: String { s("screenshotQualityCompressed") }
    static var screenshotQualityCompressedHint: String { s("screenshotQualityCompressedHint") }
    static var screenshotQualityCompressingSave: String { s("screenshotQualityCompressingSave") }
    static var screenshotQualityCompressingClipboard: String { s("screenshotQualityCompressingClipboard") }
    static var screenshotCompressionFailed: String { s("screenshotCompressionFailed") }

    // Screenshot shortcut
    static var shortcutSet: String { s("shortcutSet") }
    static var shortcutCancel: String { s("shortcutCancel") }
    static var shortcutWaiting: String { s("shortcutWaiting") }
    static var shortcutNeedsModifierTitle: String { s("shortcutNeedsModifierTitle") }
    static var shortcutNeedsModifier: String { s("shortcutNeedsModifier") }
    static var shortcutRestore: String { s("shortcutRestore") }

    // Pin-image shortcut
    static var pinToolbarClose: String { s("pinToolbarClose") }
    static var pinToolbarCopy: String { s("pinToolbarCopy") }
    static var pinToolbarDrag: String { s("pinToolbarDrag") }
    static var pinToolbarEdit: String { s("pinToolbarEdit") }
    static var pinToolbarEditText: String { s("pinToolbarEditText") }

    // Magnifier lens panel (overlay magnifier lens panel)
    static var magnifierLensPanelCoordinatesLabel: String { s("magnifierLensPanelCoordinatesLabel") }
    static var magnifierLensPanelColorValueLabel: String { s("magnifierLensPanelColorValueLabel") }
    static var magnifierLensPanelCoordinates: String { s("magnifierLensPanelCoordinates") }
    static var magnifierLensPanelRgb: String { s("magnifierLensPanelRgb") }
    static var magnifierLensPanelAspectFree: String { s("magnifierLensPanelAspectFree") }
    static func magnifierLensPanelRgbString(r: Int, g: Int, b: Int) -> String {
        String(format: s("magnifierLensPanelRgbString"), r, g, b)
    }

    // Copy-to-clipboard shortcut (editor confirm)
    // Save-to-file shortcut (editor save)
    // Shortcut conflict
    static var shortcutConflictTitle: String { s("shortcutConflictTitle") }
    static var shortcutConflictScreenshot: String { s("shortcutConflictScreenshot") }
    static var shortcutConflictQuickPin: String { s("shortcutConflictQuickPin") }
    static var shortcutConflictClipboard: String { s("shortcutConflictClipboard") }
    static var shortcutConflictFileSave: String { s("shortcutConflictFileSave") }
    static var shortcutConflictFullScreenScreenshot: String { s("shortcutConflictFullScreenScreenshot") }
    // Menu bar
    static var takeScreenshot: String { s("takeScreenshot") }
    static var takeFullScreenScreenshot: String { s("takeFullScreenScreenshot") }
    static var record: String { s("record") }
    static var settings: String { s("settings") }
    static var quitApp: String { s("quitApp") }

    // Cursor chip
    static var dragToScreenshot: String { s("dragToScreenshot") }
    static var dragToQuickPin: String { s("dragToQuickPin") }
    static var dragToScreenshotAspectFree: String { s("dragToScreenshotAspectFree") }
    static func dragToScreenshotAspect(_ ratio: String) -> String {
        String(format: s("dragToScreenshotAspect"), ratio)
    }
    static func dragToRecordAspect(_ ratio: String) -> String {
        String(format: s("dragToRecordAspect"), ratio)
    }

    // Toast
    static var copiedToClipboard: String { s("copiedToClipboard") }
    static var finderEditExitHint: String { s("finderEditExitHint") }
    static var clipboardEditExitHint: String { s("clipboardEditExitHint") }
    static var pinEditExitHint: String { s("pinEditExitHint") }
    static var fullScreenEditExitHint: String { s("fullScreenEditExitHint") }
    static var editSuspendedToast: String { s("editSuspendedToast") }
    static var editSuspendedResumeToast: String { s("editSuspendedResumeToast") }
    static var fullScreenScreenshotFailed: String { s("fullScreenScreenshotFailed") }
    static var mergeEditExitHint: String { s("mergeEditExitHint") }
    // Microphone permission row
    static func screenshotSaved(to path: String) -> String {
        String(format: s("screenshotSaved"), path)
    }
    static func screenshotSaveFailed(_ message: String) -> String {
        String(format: s("screenshotSaveFailed"), message)
    }
    static func colorCopied(_ hex: String) -> String {
        String(format: s("colorCopied"), hex)
    }
    // Toolbar tooltips
    static var tipRectangle: String { s("tipRectangle") }
    static var tipEllipse: String { s("tipEllipse") }
    static var tipArrow: String { s("tipArrow") }
    static var tipLine: String { s("tipLine") }
    static var tipPen: String { s("tipPen") }
    static var tipMosaic: String { s("tipMosaic") }
    static var mosaicBlur: String { s("mosaicBlur") }
    static var tipNumbered: String { s("tipNumbered") }
    static var tipText: String { s("tipText") }
    static var tipColorPicker: String { s("tipColorPicker") }
    static var tipPickedInkBottle: String { s("tipPickedInkBottle") }
    static var tipUndo: String { s("tipUndo") }
    static var tipRedo: String { s("tipRedo") }
    static var tipMoveSelection: String { s("tipMoveSelection") }
    static var tipSave: String { s("tipSave") }
    static var tipPin: String { s("tipPin") }
    static var windowCapturePreparing: String { s("windowCapturePreparing") }
    static var tipCancel: String { s("tipCancel") }
    static var tipConfirm: String { s("tipConfirm") }
    // Text tool
    static var textStrokeEffect: String { s("textStrokeEffect") }
    static var textCalloutEffect: String { s("textCalloutEffect") }
    // Shape tool
    static var shapeStyleRounded: String { s("shapeStyleRounded") }
    static var arrowStyleTapered: String { s("arrowStyleTapered") }
    static var arrowStyleDoubleEnded: String { s("arrowStyleDoubleEnded") }
    static var arrowStyleLine: String { s("arrowStyleLine") }
    static var arrowStyleDotTail: String { s("arrowStyleDotTail") }

    // Insert tools
    // Language
    // Settings sidebar tabs
    // Toolbar settings
    static func toolbarSettingsShortcutRecording(_ action: String) -> String {
        String(format: s("toolbarSettingsShortcutRecording"), action)
    }
    static func editorShortcutConflict(_ action: String) -> String {
        String(format: s("editorShortcutConflict"), action)
    }
    // About pane
    // Error log — About pane
    static func aboutErrorLogLastCrash(_ date: String) -> String {
        String(format: s("aboutErrorLogLastCrash"), date)
    }
    // Updates — About pane
    static func updateNewVersionStatus(_ v: String) -> String {
        String(format: s("updateNewVersionStatus"), v)
    }
    static func updateDownloadingStatus(_ percent: Int) -> String {
        String(format: s("updateDownloadingStatus"), percent)
    }
    // Updates — menu bar
    static func updateAvailableMenu(_ v: String) -> String {
        String(format: s("updateAvailableMenu"), v)
    }
    static func updateDownloadingMenu(_ percent: Int) -> String {
        String(format: s("updateDownloadingMenu"), percent)
    }
    // Updates — progress HUD
    static func updateDownloadingHUD(_ percent: Int) -> String {
        String(format: s("updateDownloadingHUD"), percent)
    }
    // Updates — manual check result alert
    static func updateAvailableTitle(_ v: String) -> String {
        String(format: s("updateAvailableTitle"), v)
    }
    static func updateUpToDateBody(_ v: String) -> String {
        String(format: s("updateUpToDateBody"), v)
    }
    // Quit confirmation dialog
    // Upload — toolbar / toast / progress
    static func filenameRulePreview(_ value: String) -> String {
        String(format: s("filenameRulePreview"), value)
    }

    // Upload — provider names
    static func missingField(_ key: String) -> String {
        String(format: s("missingField"), key)
    }

    // Permissions — status label
    // OCR & Translation — result panel
    // Translation — target language names
}

struct Defaults {
    static var defaults: UserDefaults {
        UserDefaults.standard
    }

    /// Reads a persisted size-tier index; a missing key or anything outside
    /// 0...2 (including legacy continuous values) falls back to the medium
    /// tier — `integer(forKey:)` returns 0 for absent keys, so the presence
    /// check must come first or a fresh install would default to small.
    private static func tierValue(_ key: String) -> Int {
        guard defaults.object(forKey: key) != nil else { return 1 }
        let raw = defaults.integer(forKey: key)
        return (0...2).contains(raw) ? raw : 1
    }

    static var doubleTapInterval: TimeInterval {
        get {
            let val = defaults.double(forKey: "doubleTapInterval")
            return val > 0 ? val : 0.3
        }
        set {
            defaults.set(newValue, forKey: "doubleTapInterval")
        }
    }

    // Custom screenshot hotkey. When the key is absent, no custom hotkey is set
    // (fall back to double-tap ⌘). keyCode 0 is a valid value — it is the `A` key
    // (kVK_ANSI_A) — so presence must be checked via `hasCustomScreenshotHotkey`,
    // never by comparing the key code to 0.
    // Modifiers are stored using Carbon flags (cmdKey | shiftKey | optionKey | controlKey).

    static var screenshotHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "screenshotHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "screenshotHotkeyKeyCode") }
    }

    static var screenshotHotkeyModifiers: Int {
        get { defaults.integer(forKey: "screenshotHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "screenshotHotkeyModifiers") }
    }

    static var hasCustomScreenshotHotkey: Bool {
        defaults.object(forKey: "screenshotHotkeyKeyCode") != nil
    }

    static func clearScreenshotHotkey() {
        defaults.removeObject(forKey: "screenshotHotkeyKeyCode")
        defaults.removeObject(forKey: "screenshotHotkeyModifiers")
    }

    static let selectionAspectRatioPresets: [CGFloat] = [
        1.0,
        2.35,
        3.0,
        3.0 / 2.0,
        4.0 / 3.0,
        9.0 / 16.0,
        16.0 / 9.0,
    ]

    static var selectionAspectRatio: Double {
        get {
            let ratio = defaults.double(forKey: "selectionAspectRatio")
            return ratio > 0 && ratio.isFinite ? ratio : 0
        }
        set {
            guard newValue > 0, newValue.isFinite else {
                clearSelectionAspectRatio()
                return
            }
            defaults.set(newValue, forKey: "selectionAspectRatio")
        }
    }

    static var hasSelectionAspectRatio: Bool {
        defaults.object(forKey: "selectionAspectRatio") != nil && selectionAspectRatio > 0
    }

    static func clearSelectionAspectRatio() {
        defaults.removeObject(forKey: "selectionAspectRatio")
    }

    private static func clearLegacyPinHotkey() {
        defaults.removeObject(forKey: "pinHotkeyKeyCode")
        defaults.removeObject(forKey: "pinHotkeyModifiers")
    }

    // Custom pin-image hotkeys. They are global Carbon hotkeys with no
    // defaults: users opt in from Settings. Quick Pin captures a screen
    // selection; the other shortcuts read Finder or clipboard content.

    static var quickPinHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "quickPinHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "quickPinHotkeyKeyCode") }
    }

    static var quickPinHotkeyModifiers: Int {
        get { defaults.integer(forKey: "quickPinHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "quickPinHotkeyModifiers") }
    }

    static var hasCustomQuickPinHotkey: Bool {
        defaults.object(forKey: "quickPinHotkeyKeyCode") != nil
    }

    static func clearQuickPinHotkey() {
        defaults.removeObject(forKey: "quickPinHotkeyKeyCode")
        defaults.removeObject(forKey: "quickPinHotkeyModifiers")
    }

    static func resetShortcutHotkeysToDefaults() {
        clearScreenshotHotkey()
        clearLegacyPinHotkey()
        clearQuickPinHotkey()
        clearTextRecognitionHotkey()
        clearCopyImageTextHotkey()
        clearFullScreenScreenshotHotkey()
        clearClipboardHotkey()
        clearFileSaveHotkey()
    }

    // Custom image-edit hotkeys. They are global Carbon hotkeys with no
    // defaults: users opt in from Settings. The selected-image shortcut reads
    // one image selected in Finder; the clipboard-image shortcut reads only
    // the clipboard image.

    // Custom OCR/translation hotkeys. They are global Carbon hotkeys with no
    // defaults: users opt in from Settings, then select a region that is sent
    // straight to the corresponding result panel.

    static var textRecognitionHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "textRecognitionHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "textRecognitionHotkeyKeyCode") }
    }

    static var textRecognitionHotkeyModifiers: Int {
        get { defaults.integer(forKey: "textRecognitionHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "textRecognitionHotkeyModifiers") }
    }

    static var hasCustomTextRecognitionHotkey: Bool {
        defaults.object(forKey: "textRecognitionHotkeyKeyCode") != nil
    }

    static func clearTextRecognitionHotkey() {
        defaults.removeObject(forKey: "textRecognitionHotkeyKeyCode")
        defaults.removeObject(forKey: "textRecognitionHotkeyModifiers")
    }

    static var copyImageTextHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "copyImageTextHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "copyImageTextHotkeyKeyCode") }
    }

    static var copyImageTextHotkeyModifiers: Int {
        get { defaults.integer(forKey: "copyImageTextHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "copyImageTextHotkeyModifiers") }
    }

    static var hasCustomCopyImageTextHotkey: Bool {
        defaults.object(forKey: "copyImageTextHotkeyKeyCode") != nil
    }

    static func clearCopyImageTextHotkey() {
        defaults.removeObject(forKey: "copyImageTextHotkeyKeyCode")
        defaults.removeObject(forKey: "copyImageTextHotkeyModifiers")
    }

    static var recordHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "recordHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "recordHotkeyKeyCode") }
    }

    static var recordHotkeyModifiers: Int {
        get { defaults.integer(forKey: "recordHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "recordHotkeyModifiers") }
    }

    static var fullScreenScreenshotHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "fullScreenScreenshotHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "fullScreenScreenshotHotkeyKeyCode") }
    }

    static var fullScreenScreenshotHotkeyModifiers: Int {
        get { defaults.integer(forKey: "fullScreenScreenshotHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "fullScreenScreenshotHotkeyModifiers") }
    }

    static var hasCustomFullScreenScreenshotHotkey: Bool {
        defaults.object(forKey: "fullScreenScreenshotHotkeyKeyCode") != nil
    }

    static func clearFullScreenScreenshotHotkey() {
        defaults.removeObject(forKey: "fullScreenScreenshotHotkeyKeyCode")
        defaults.removeObject(forKey: "fullScreenScreenshotHotkeyModifiers")
    }

    /// When true (default), screenshot "Save to file" shows a save panel.
    /// When false, screenshots write straight to `screenshotSaveDirectory`.
    static var askSaveLocation: Bool {
        get {
            if defaults.object(forKey: "askSaveLocation") == nil {
                return true
            }
            return defaults.bool(forKey: "askSaveLocation")
        }
        set {
            defaults.set(newValue, forKey: "askSaveLocation")
        }
    }

    static var autoRevealSavedFiles: Bool {
        get {
            if defaults.object(forKey: "autoRevealSavedFiles") == nil {
                return true
            }
            return defaults.bool(forKey: "autoRevealSavedFiles")
        }
        set {
            defaults.set(newValue, forKey: "autoRevealSavedFiles")
        }
    }

    static var defaultScreenshotSaveDirectory: URL {
        defaultDocumentsDirectory.appendingPathComponent("screenshots", isDirectory: true)
    }

    static var screenshotSaveDirectory: URL {
        get {
            normalizedDirectoryURL(
                defaults.string(forKey: "screenshotSaveDirectory"),
                fallback: defaultScreenshotSaveDirectory
            )
        }
        set {
            defaults.set(newValue.standardizedFileURL.path, forKey: "screenshotSaveDirectory")
        }
    }

    static var screenshotSaveQuality: ScreenshotImageQuality {
        get { screenshotQuality(forKey: "screenshotSaveQuality") }
        set { defaults.set(newValue.rawValue, forKey: "screenshotSaveQuality") }
    }

    static var screenshotClipboardQuality: ScreenshotImageQuality {
        get { screenshotQuality(forKey: "screenshotClipboardQuality") }
        set { defaults.set(newValue.rawValue, forKey: "screenshotClipboardQuality") }
    }

    private static func screenshotQuality(forKey key: String) -> ScreenshotImageQuality {
        guard let raw = defaults.string(forKey: key) else {
            return ScreenshotImageQuality.defaultValue
        }
        if raw == "balanced" || raw == "compact" {
            return .compressed
        }
        return ScreenshotImageQuality(rawValue: raw) ?? ScreenshotImageQuality.defaultValue
    }

    static let defaultImageFilenameTemplate = "wxshot-{date}-{time}"

    static var imageFilenameTemplate: String {
        get {
            normalizedFilenameTemplate(
                defaults.string(forKey: "imageFilenameTemplate"),
                fallback: defaultImageFilenameTemplate
            )
        }
        set {
            defaults.set(
                normalizedFilenameTemplate(newValue, fallback: defaultImageFilenameTemplate),
                forKey: "imageFilenameTemplate"
            )
        }
    }

    private static func normalizedFilenameTemplate(_ value: String?, fallback: String) -> String {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static var defaultDocumentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents", isDirectory: true)
    }

    private static func normalizedDirectoryURL(_ value: String?, fallback: URL) -> URL {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fallback.standardizedFileURL }
        let expanded = (trimmed as NSString).expandingTildeInPath
        return URL(fileURLWithPath: expanded, isDirectory: true).standardizedFileURL
    }

    static func filenameSequenceValue(scope: String, dayStamp: String?, consume: Bool) -> Int {
        if let dayStamp {
            let counterKey = "filenameDailyCounter.\(scope)"
            let dayKey = "filenameDailyCounterDay.\(scope)"
            let currentDay = defaults.string(forKey: dayKey)
            let currentValue = currentDay == dayStamp ? defaults.integer(forKey: counterKey) : 0
            let nextValue = currentValue + 1
            if consume {
                defaults.set(dayStamp, forKey: dayKey)
                defaults.set(nextValue, forKey: counterKey)
            }
            return nextValue
        }

        let key = "filenameCounter.\(scope)"
        let nextValue = defaults.integer(forKey: key) + 1
        if consume {
            defaults.set(nextValue, forKey: key)
        }
        return nextValue
    }

    // Custom copy-to-clipboard hotkey used inside the editor overlay to
    // confirm the screenshot. When absent, the default is "double-tap ⌘",
    // detected via the global flag monitor (KeyMonitor) — see AppDelegate.
    // Unlike the screenshot and pin hotkeys this is matched locally against
    // keyDown events instead of registered as a Carbon global hotkey, so it
    // may be bare (no modifiers). Presence must be checked via
    // `hasCustomClipboardHotkey` since key code 0 (`A`) is a valid value.

    private static func migrateLegacySaveHotkeyIfNeeded() {
        // wxShot ≤ 1.x stored this same hotkey under "saveHotkey*". Migrate
        // once on first read so existing users don't lose their binding.
        let migratedKey = "clipboardHotkeyMigrated"
        guard !defaults.bool(forKey: migratedKey) else { return }
        defaults.set(true, forKey: migratedKey)
        guard defaults.object(forKey: "saveHotkeyKeyCode") != nil,
              defaults.object(forKey: "clipboardHotkeyKeyCode") == nil
        else { return }
        defaults.set(defaults.integer(forKey: "saveHotkeyKeyCode"), forKey: "clipboardHotkeyKeyCode")
        defaults.set(defaults.integer(forKey: "saveHotkeyModifiers"), forKey: "clipboardHotkeyModifiers")
        defaults.removeObject(forKey: "saveHotkeyKeyCode")
        defaults.removeObject(forKey: "saveHotkeyModifiers")
    }

    static var clipboardHotkeyKeyCode: Int {
        get {
            migrateLegacySaveHotkeyIfNeeded()
            return defaults.integer(forKey: "clipboardHotkeyKeyCode")
        }
        set { defaults.set(newValue, forKey: "clipboardHotkeyKeyCode") }
    }

    static var clipboardHotkeyModifiers: Int {
        get {
            migrateLegacySaveHotkeyIfNeeded()
            return defaults.integer(forKey: "clipboardHotkeyModifiers")
        }
        set { defaults.set(newValue, forKey: "clipboardHotkeyModifiers") }
    }

    static var hasCustomClipboardHotkey: Bool {
        migrateLegacySaveHotkeyIfNeeded()
        return defaults.object(forKey: "clipboardHotkeyKeyCode") != nil
    }

    static func clearClipboardHotkey() {
        defaults.removeObject(forKey: "clipboardHotkeyKeyCode")
        defaults.removeObject(forKey: "clipboardHotkeyModifiers")
    }

    // Custom save-to-file hotkey used inside the editor overlay to invoke
    // the configured-directory file save. When absent, defaults to ⌘S.
    // Matched locally against keyDown events, same as the clipboard hotkey.

    static var fileSaveHotkeyKeyCode: Int {
        get { defaults.integer(forKey: "fileSaveHotkeyKeyCode") }
        set { defaults.set(newValue, forKey: "fileSaveHotkeyKeyCode") }
    }

    static var fileSaveHotkeyModifiers: Int {
        get { defaults.integer(forKey: "fileSaveHotkeyModifiers") }
        set { defaults.set(newValue, forKey: "fileSaveHotkeyModifiers") }
    }

    static var hasCustomFileSaveHotkey: Bool {
        defaults.object(forKey: "fileSaveHotkeyKeyCode") != nil
    }

    static func clearFileSaveHotkey() {
        defaults.removeObject(forKey: "fileSaveHotkeyKeyCode")
        defaults.removeObject(forKey: "fileSaveHotkeyModifiers")
    }

    // History navigation hotkeys used inside the editor overlay. Defaults are
    // comma for previous and period for next. Like clipboard/save editor
    // hotkeys, bare keys are allowed because matching is local to the editor.

    // History panel shortcut. Defaults to unset; users can opt in from
    // Settings. The global hotkey opens the dialog mode when enabled, or the
    // notch mode when dialog mode is disabled.

    static var penColor: Int {
        get {
            let val = defaults.integer(forKey: "penColor")
            return val == 0 ? 0xFF0000 : val
        }
        set {
            defaults.set(newValue, forKey: "penColor")
        }
    }

    static var penWidth: Double {
        get {
            let val = defaults.double(forKey: "penWidth")
            return val > 0 ? val : 3.0
        }
        set {
            defaults.set(newValue, forKey: "penWidth")
        }
    }

    /// Size presets: tier index 0 = small, 1 = medium (default), 2 = large.
    /// Tier indexes are persisted directly; any stored value outside 0...2
    /// (e.g. legacy continuous sizes) is ignored and falls back to medium.
    
    static var lastEditorColorHex: String? {
        get {
            normalizedHexColor(defaults.string(forKey: "lastEditorColorHex"))
        }
        set {
            if let normalized = normalizedHexColor(newValue) {
                defaults.set(normalized, forKey: "lastEditorColorHex")
            } else {
                defaults.removeObject(forKey: "lastEditorColorHex")
            }
        }
    }

    static var lastLineWidthTier: Int {
        get { tierValue("lastLineWidthTier") }
        set { defaults.set(newValue, forKey: "lastLineWidthTier") }
    }

    static var lastNumberSizeTier: Int {
        get { tierValue("lastNumberSizeTier") }
        set { defaults.set(newValue, forKey: "lastNumberSizeTier") }
    }


    static var lastMosaicSizeTier: Int {
        get { tierValue("lastMosaicSizeTier") }
        set { defaults.set(newValue, forKey: "lastMosaicSizeTier") }
    }


    static var mosaicStyle: MosaicStyle {
        get { MosaicStyle(rawValue: defaults.string(forKey: "mosaicStyle") ?? "") ?? .pixelate }
        set { defaults.set(newValue.rawValue, forKey: "mosaicStyle") }
    }


    static var lastMosaicBlurTier: Int {
        get { tierValue("lastMosaicBlurTier") }
        set { defaults.set(newValue, forKey: "lastMosaicBlurTier") }
    }



    static var lastFontSizeTier: Int {
        get { tierValue("lastFontSizeTier") }
        set { defaults.set(newValue, forKey: "lastFontSizeTier") }
    }

    /// Default font family for text annotations. Shared by the settings pane
    /// and the editor's font picker (which also writes it, matching the
    /// "remember last used" model of the other text-tool properties).
    /// Normalized at the persistence boundary: a family that is no longer
    /// installed reads back as nil, i.e. the system bold default.

    /// Whether the text tool's outline checkbox was last left on.
    static var lastTextStroke: Bool {
        get { defaults.bool(forKey: "lastTextStroke") }
        set { defaults.set(newValue, forKey: "lastTextStroke") }
    }

    /// Whether the text tool's callout checkbox was last left on.
    static var lastTextCallout: Bool {
        get { defaults.bool(forKey: "lastTextCallout") }
        set { defaults.set(newValue, forKey: "lastTextCallout") }
    }

    /// Last rectangle/ellipse fill mode. Migrates the previous checkbox
    /// preference by treating its "on" state as the old opaque fill.
    static var lastShapeStrokeStyle: ShapeStrokeStyle {
        get {
            guard let raw = defaults.string(forKey: "lastShapeStrokeStyle"),
                  let style = ShapeStrokeStyle(rawValue: raw) else {
                return .standard
            }
            return style
        }
        set {
            defaults.set(newValue.rawValue, forKey: "lastShapeStrokeStyle")
        }
    }

    static var lastArrowStyle: ArrowStyle {
        get {
            guard let raw = defaults.string(forKey: "lastArrowStyle"),
                  let style = ArrowStyle(rawValue: raw) else {
                return .tapered
            }
            return style
        }
        set {
            defaults.set(newValue.rawValue, forKey: "lastArrowStyle")
        }
    }

    private static func normalizedHexColor(_ hex: String?) -> String? {
        guard var trimmed = hex?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() else {
            return nil
        }
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        guard trimmed.count == 6, UInt32(trimmed, radix: 16) != nil else { return nil }
        return "#\(trimmed)"
    }

    private static func clampedUnitInterval(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    private static func normalizedMagnifierLensPanelMagnifiedSize(_ value: Int) -> Int {
        switch value {
        case 96, 144, 192:
            return value
        default:
            return 144
        }
    }

    private static func normalizedMagnifierLensPanelMagnification(_ value: Double) -> Double {
        guard value.isFinite else { return 4.0 }
        return min(16.0, max(1.0, value))
    }

    private static func normalizedUniqueStringList(_ values: [String], limit: Int) -> [String] {
        var result: [String] = []
        for value in values {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, !result.contains(trimmed) else { continue }
            result.append(trimmed)
            if result.count == limit { break }
        }
        return result
    }

    /// Background color used in dark mode (when `magnifierLensPanelFollowSystemAppearance` is on).
    /// Stored as 0–1 RGBA components. Default: black with 80% alpha.
    static var magnifierLensPanelDarkBackgroundRed: Double {
        get { defaults.object(forKey: "magnifierLensPanelDarkBackgroundRed") == nil ? 0 : defaults.double(forKey: "magnifierLensPanelDarkBackgroundRed") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelDarkBackgroundRed") }
    }
    static var magnifierLensPanelDarkBackgroundGreen: Double {
        get { defaults.object(forKey: "magnifierLensPanelDarkBackgroundGreen") == nil ? 0 : defaults.double(forKey: "magnifierLensPanelDarkBackgroundGreen") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelDarkBackgroundGreen") }
    }
    static var magnifierLensPanelDarkBackgroundBlue: Double {
        get { defaults.object(forKey: "magnifierLensPanelDarkBackgroundBlue") == nil ? 0 : defaults.double(forKey: "magnifierLensPanelDarkBackgroundBlue") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelDarkBackgroundBlue") }
    }
    static var magnifierLensPanelDarkBackgroundAlpha: Double {
        get { defaults.object(forKey: "magnifierLensPanelDarkBackgroundAlpha") == nil ? 0.80 : defaults.double(forKey: "magnifierLensPanelDarkBackgroundAlpha") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelDarkBackgroundAlpha") }
    }

    /// Background color used in light mode (when `magnifierLensPanelFollowSystemAppearance` is on).
    /// Stored as 0–1 RGBA components. Default: white with 80% alpha.
    static var magnifierLensPanelLightBackgroundRed: Double {
        get { defaults.object(forKey: "magnifierLensPanelLightBackgroundRed") == nil ? 1 : defaults.double(forKey: "magnifierLensPanelLightBackgroundRed") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelLightBackgroundRed") }
    }
    static var magnifierLensPanelLightBackgroundGreen: Double {
        get { defaults.object(forKey: "magnifierLensPanelLightBackgroundGreen") == nil ? 1 : defaults.double(forKey: "magnifierLensPanelLightBackgroundGreen") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelLightBackgroundGreen") }
    }
    static var magnifierLensPanelLightBackgroundBlue: Double {
        get { defaults.object(forKey: "magnifierLensPanelLightBackgroundBlue") == nil ? 1 : defaults.double(forKey: "magnifierLensPanelLightBackgroundBlue") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelLightBackgroundBlue") }
    }
    static var magnifierLensPanelLightBackgroundAlpha: Double {
        get { defaults.object(forKey: "magnifierLensPanelLightBackgroundAlpha") == nil ? 0.80 : defaults.double(forKey: "magnifierLensPanelLightBackgroundAlpha") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelLightBackgroundAlpha") }
    }

    /// When `true`, the lens picks the dark/light background color based on the
    /// current macOS appearance. When `false`, the dark color is always used.
    static var magnifierLensPanelFollowSystemAppearance: Bool {
        get {
            if defaults.object(forKey: "magnifierLensPanelFollowSystemAppearance") == nil {
                return true
            }
            return defaults.bool(forKey: "magnifierLensPanelFollowSystemAppearance")
        }
        set {
            defaults.set(newValue, forKey: "magnifierLensPanelFollowSystemAppearance")
        }
    }

    /// Side length (in points) of the magnified area. One of 96, 144, 192.
    static var magnifierLensPanelMagnifiedSize: Int {
        get {
            if defaults.object(forKey: "magnifierLensPanelMagnifiedSize") == nil {
                return 144
            }
            return normalizedMagnifierLensPanelMagnifiedSize(defaults.integer(forKey: "magnifierLensPanelMagnifiedSize"))
        }
        set {
            defaults.set(normalizedMagnifierLensPanelMagnifiedSize(newValue), forKey: "magnifierLensPanelMagnifiedSize")
        }
    }

    /// Magnification factor for the lens. Controls how many source pixels are
    /// sampled: source region = magnified display size / magnification.
    /// Higher values = tighter zoom (smaller source region). Default 4×,
    /// clamped to 1×...16× for hidden UserDefaults overrides.
    static var magnifierLensPanelMagnification: Double {
        get {
            if defaults.object(forKey: "magnifierLensPanelMagnification") == nil {
                return 4.0
            }
            return normalizedMagnifierLensPanelMagnification(
                defaults.double(forKey: "magnifierLensPanelMagnification")
            )
        }
        set {
            defaults.set(
                normalizedMagnifierLensPanelMagnification(newValue),
                forKey: "magnifierLensPanelMagnification"
            )
        }
    }

    /// Horizontal offset (in points) between the cursor and the panel's left edge.
    static var magnifierLensPanelOffsetX: Double {
        get {
            if defaults.object(forKey: "magnifierLensPanelOffsetX") == nil {
                return 15
            }
            return defaults.double(forKey: "magnifierLensPanelOffsetX")
        }
        set {
            defaults.set(newValue, forKey: "magnifierLensPanelOffsetX")
        }
    }

    /// Vertical offset (in points) between the cursor and the panel's top edge
    /// when the panel sits below the cursor.
    static var magnifierLensPanelOffsetY: Double {
        get {
            if defaults.object(forKey: "magnifierLensPanelOffsetY") == nil {
                return 15
            }
            return defaults.double(forKey: "magnifierLensPanelOffsetY")
        }
        set {
            defaults.set(newValue, forKey: "magnifierLensPanelOffsetY")
        }
    }

    /// Whether to show the "Press ⌘+C to copy color" hint row in the lens.
    static var magnifierLensPanelShowCopyHint: Bool {
        get {
            if defaults.object(forKey: "magnifierLensPanelShowCopyHint") == nil {
                return true
            }
            return defaults.bool(forKey: "magnifierLensPanelShowCopyHint")
        }
        set {
            defaults.set(newValue, forKey: "magnifierLensPanelShowCopyHint")
        }
    }

    /// Whether to show the "Press F to switch color format" hint row in the lens.
    /// The stored key keeps its original name for preference compatibility.
    static var magnifierLensPanelShowFormatHint: Bool {
        get {
            if defaults.object(forKey: "magnifierLensPanelShowShiftHint") == nil {
                return true
            }
            return defaults.bool(forKey: "magnifierLensPanelShowShiftHint")
        }
        set {
            defaults.set(newValue, forKey: "magnifierLensPanelShowShiftHint")
        }
    }

    /// Coordinate mode for the lens display: `.points` shows AppKit
    /// screen-point coordinates (default); `.pixels` shows physical
    /// CGImage pixel coordinates matching the snapshot resolution.
    enum MagnifierLensPanelCoordinateMode: String {
        case points
        case pixels
    }
    static var magnifierLensPanelCoordinateMode: MagnifierLensPanelCoordinateMode {
        get {
            guard let raw = defaults.string(forKey: "magnifierLensPanelCoordinateMode"),
                  let mode = MagnifierLensPanelCoordinateMode(rawValue: raw) else {
                return .pixels
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: "magnifierLensPanelCoordinateMode")
        }
    }

    /// Crosshair colour — RGBA components stored as 0–1 doubles.
    /// Default: #A8BDFC at 65% alpha.
    static var magnifierLensPanelCrosshairRed: Double {
        get { defaults.object(forKey: "magnifierLensPanelCrosshairRed") == nil ? 0xA8 / 255.0 : defaults.double(forKey: "magnifierLensPanelCrosshairRed") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelCrosshairRed") }
    }
    static var magnifierLensPanelCrosshairGreen: Double {
        get { defaults.object(forKey: "magnifierLensPanelCrosshairGreen") == nil ? 0xBD / 255.0 : defaults.double(forKey: "magnifierLensPanelCrosshairGreen") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelCrosshairGreen") }
    }
    static var magnifierLensPanelCrosshairBlue: Double {
        get { defaults.object(forKey: "magnifierLensPanelCrosshairBlue") == nil ? 0xFC / 255.0 : defaults.double(forKey: "magnifierLensPanelCrosshairBlue") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelCrosshairBlue") }
    }
    static var magnifierLensPanelCrosshairAlpha: Double {
        get { defaults.object(forKey: "magnifierLensPanelCrosshairAlpha") == nil ? 0.65 : defaults.double(forKey: "magnifierLensPanelCrosshairAlpha") }
        set { defaults.set(clampedUnitInterval(newValue), forKey: "magnifierLensPanelCrosshairAlpha") }
    }

    /// Crosshair line width in points. Default 6, clamped to 1–30.
    static var magnifierLensPanelCrosshairWidth: Double {
        get {
            if defaults.object(forKey: "magnifierLensPanelCrosshairWidth") == nil { return 6 }
            return defaults.double(forKey: "magnifierLensPanelCrosshairWidth")
        }
        set { defaults.set(min(30, max(1, newValue)), forKey: "magnifierLensPanelCrosshairWidth") }
    }

    static var showMenuBar: Bool {
        get {
            if defaults.object(forKey: "showMenuBar") == nil {
                return false
            }
            return defaults.bool(forKey: "showMenuBar")
        }
        set {
            defaults.set(newValue, forKey: "showMenuBar")
        }
    }

    static var pinAcrossSpaces: Bool {
        get { defaults.bool(forKey: "pinAcrossSpaces") }
        set { defaults.set(newValue, forKey: "pinAcrossSpaces") }
    }

    // Window-capture drop shadow. When enabled, single-window screenshots get
    // rounded corners and a macOS-style drop shadow in the final output.
    // Rounded corners are always applied to window captures; this toggle only
    // governs the shadow.

    static let windowShadowSizeMin: Double = 6
    static let windowShadowSizeMax: Double = 60

    static var windowShadowEnabled: Bool {
        get {
            if defaults.object(forKey: "windowShadowEnabled") == nil {
                return false
            }
            return defaults.bool(forKey: "windowShadowEnabled")
        }
        set {
            defaults.set(newValue, forKey: "windowShadowEnabled")
        }
    }

    static var windowShadowSize: Double {
        get {
            if defaults.object(forKey: "windowShadowSize") == nil {
                return 22
            }
            let val = defaults.double(forKey: "windowShadowSize")
            return min(max(val, windowShadowSizeMin), windowShadowSizeMax)
        }
        set {
            defaults.set(min(max(newValue, windowShadowSizeMin), windowShadowSizeMax), forKey: "windowShadowSize")
        }
    }

    static var language: AppLanguage {
        get {
            // Explicit user choice wins; otherwise follow the system locale on
            // first launch so a fresh install opens in a familiar language.
            if let raw = defaults.string(forKey: "appLanguage"),
               let lang = AppLanguage(rawValue: raw) {
                return lang
            }
            return AppLanguage.systemDefault
        }
        set {
            let old = language
            defaults.set(newValue.rawValue, forKey: "appLanguage")
            if newValue != old {
                NotificationCenter.default.post(name: .languageDidChange, object: nil)
            }
        }
    }
}
