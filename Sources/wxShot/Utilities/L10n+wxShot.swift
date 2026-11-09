import Foundation

/// wxShot-specific strings (see scripts/add_strings.py for the translations).
extension L10n {
    private static func w(_ key: String) -> String { Localizer.string(key) }

    static var wxSettingsWindowTitle: String { w("wxSettingsWindowTitle") }
    static var wxSectionShortcut: String { w("wxSectionShortcut") }
    static var wxShortcutDefaultNote: String { w("wxShortcutDefaultNote") }
    static var wxSectionWeChat: String { w("wxSectionWeChat") }
    static var wxPolicyAuto: String { w("wxPolicyAuto") }
    static var wxPolicyAlways: String { w("wxPolicyAlways") }
    static var wxPolicyYield: String { w("wxPolicyYield") }
    static var wxPolicyHint: String { w("wxPolicyHint") }
    static var wxWeChatStatusNotRunning: String { w("wxWeChatStatusNotRunning") }
    static var wxWeChatStatusLoginScreen: String { w("wxWeChatStatusLoginScreen") }
    static var wxWeChatStatusLoggedIn: String { w("wxWeChatStatusLoggedIn") }
    static func wxShortcutOwner(_ owner: String) -> String { String(format: w("wxShortcutOwner"), owner) }
    static var wxOwnerWeChat: String { w("wxOwnerWeChat") }
    static var wxSectionGeneral: String { w("wxSectionGeneral") }
    static var wxPermissionStatusGranted: String { w("wxPermissionStatusGranted") }
    static var wxPermissionStatusMissing: String { w("wxPermissionStatusMissing") }
    static var wxOpenSystemSettings: String { w("wxOpenSystemSettings") }
    static var wxWelcomeTitle: String { w("wxWelcomeTitle") }
    static var wxWelcomeBody: String { w("wxWelcomeBody") }
    static var wxStepPermission: String { w("wxStepPermission") }
    static var wxStepPermissionNote: String { w("wxStepPermissionNote") }
    static func wxStepShortcut(_ shortcut: String) -> String { String(format: w("wxStepShortcut"), shortcut) }
    static var wxStepShortcutNote: String { w("wxStepShortcutNote") }
    static var wxStartButton: String { w("wxStartButton") }
    static var wxLaterButton: String { w("wxLaterButton") }
    static var wxConfirmDiscard: String { w("wxConfirmDiscard") }
    static var wxTipSettings: String { w("wxTipSettings") }
    static var wxTipShare: String { w("wxTipShare") }
    static var wxTipMore: String { w("wxTipMore") }
    static var wxTranslateHeader: String { w("wxTranslateHeader") }
    static var wxTranslating: String { w("wxTranslating") }
    static var wxTranslateUnsupported: String { w("wxTranslateUnsupported") }
    static var wxTranslateFailed: String { w("wxTranslateFailed") }
    static var wxLensCopyHint: String { w("wxLensCopyHint") }
    static var wxScrollTooFast: String { w("wxScrollTooFast") }
    static var wxLongShotCopied: String { w("wxLongShotCopied") }
}
