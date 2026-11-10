import AppKit

/// Stable identifier for every button that can appear in the editor's
/// toolbars. Raw values are persisted in `UserDefaults`, so existing cases
/// must never be renamed — only added or deprecated.
enum ToolbarItemID: String, Codable, CaseIterable {
    // Annotation tools (toggle an `EditTool`)
    case rectangle
    case ellipse
    case arrow
    case line
    case pen
    case mosaic
    case numbered
    case text
    // Stateful actions
    case colorPicker
    case undo
    case redo
    case moveSelection
    // Output actions
    case save
    case pin
    case close
    case confirm
    case settings
    case share
}

extension ToolbarItemID {
    /// How the button behaves — drives which `on*` callback it fires and
    /// whether it carries a persistent selected/active state.
    enum Kind {
        /// Annotation tool — selecting it toggles an `EditTool`.
        case toggleTool
        /// Fires once on click, no persistent state.
        case momentary
        /// Press-and-drag handle (move selection) — not a tappable button.
        case dragHandle
    }

    var kind: Kind {
        switch self {
        case .rectangle, .ellipse, .arrow, .line, .pen, .mosaic, .numbered, .text:
            return .toggleTool
        case .moveSelection:
            return .dragHandle
        case .colorPicker, .undo, .redo, .save, .pin, .close, .confirm, .settings, .share:
            return .momentary
        }
    }

    /// The annotation tool a `toggleTool` item maps to; `nil` for all others.
    var editTool: EditTool? {
        switch self {
        case .rectangle: return .rectangle
        case .ellipse:   return .ellipse
        case .arrow:     return .arrow
        case .line:      return .line
        case .pen:       return .pen
        case .mosaic:    return .mosaic
        case .numbered:  return .numbered
        case .text:      return .text
        default:         return nil
        }
    }

    var symbolName: String {
        switch self {
        case .rectangle:     return "rectangle"
        case .ellipse:       return "circle"
        case .arrow:         return "arrow.up.right"
        case .line:          return "line.diagonal"
        case .pen:           return "pencil"
        case .mosaic:        return "square.grid.3x3"
        case .numbered:      return "1.circle"
        case .text:          return "textformat"
        case .colorPicker:   return "eyedropper"
        case .undo:          return "arrow.uturn.backward"
        case .redo:          return "arrow.uturn.forward"
        case .moveSelection: return "arrow.up.and.down.and.arrow.left.and.right"
        case .save:          return "square.and.arrow.down"
        case .pin:           return "pin"
        case .close:         return "xmark"
        case .confirm:       return "checkmark"
        case .settings:      return "gearshape"
        case .share:         return "arrowshape.turn.up.right"
        }
    }

    func iconImage(pointSize: CGFloat) -> NSImage? {
        if let drawn = ToolbarIcons.image(for: self) { return drawn }
        guard let base = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
            return nil
        }
        let config = NSImage.SymbolConfiguration(pointSize: pointSize + 1, weight: self == .settings ? .light : .medium)
        let locale: Locale? = switch self {
        case .text: Locale(identifier: "en")
        default: nil
        }
        return (locale.map { base.withLocale($0) } ?? base).withSymbolConfiguration(config)
    }

    var localizedTitle: String {
        switch self {
        case .rectangle:     return L10n.tipRectangle
        case .ellipse:       return L10n.tipEllipse
        case .arrow:         return L10n.tipArrow
        case .line:          return L10n.tipLine
        case .pen:           return L10n.tipPen
        case .mosaic:        return L10n.tipMosaic
        case .numbered:      return L10n.tipNumbered
        case .text:          return L10n.tipText
        case .colorPicker:   return L10n.tipColorPicker
        case .undo:          return L10n.tipUndo
        case .redo:          return L10n.tipRedo
        case .moveSelection: return L10n.tipMoveSelection
        case .save:          return L10n.tipSave
        case .pin:           return L10n.tipPin
        case .close:         return L10n.tipCancel
        case .confirm:       return L10n.tipConfirm
        case .settings:      return L10n.wxTipSettings
        case .share:         return L10n.wxTipShare
        }
    }

    /// Localized hover-tooltip text with the current configured shortcut.
    var tooltip: String {
        guard let shortcut = editorShortcutDisplay else { return localizedTitle }
        return "\(localizedTitle) (\(shortcut))"
    }

    var editorShortcutDisplay: String? {
        guard supportsEditorShortcut else { return nil }
        return EditorShortcutRegistry.displayString(for: .toolbar(self))
    }

    /// Icon tint in the resting state.
    var normalColor: NSColor {
        switch self {
        case .close:   return toolbarDangerRed
        case .confirm: return toolbarConfirmGreen
        default:       return toolbarIconGray
        }
    }

    /// Icon tint while selected/active. For `momentary` items this equals
    /// `normalColor` — they never enter a selected state.
    var selectedColor: NSColor {
        switch kind {
        case .toggleTool:
            return toolbarConfirmGreen
        case .momentary, .dragHandle:
            return normalColor
        }
    }
}

/// Red used for the cancel button's icon. Mirrors the literal previously
/// inlined in `ToolbarView.setupButtons()`.
let toolbarDangerRed = NSColor(srgbRed: 0.89, green: 0.35, blue: 0.32, alpha: 1)
let toolbarConfirmGreen = NSColor(srgbRed: 0.24, green: 0.72, blue: 0.42, alpha: 1)
let toolbarIconGray = NSColor(srgbRed: 0.353, green: 0.353, blue: 0.353, alpha: 1)

/// User-customizable assignment of every toolbar item to the primary
/// (horizontal) toolbar, the side (vertical) toolbar, or hidden.
struct ToolbarLayout: Equatable {
    var primary: [ToolbarItemID]
    var side: [ToolbarItemID]
    var hidden: [ToolbarItemID]

    /// Canonical left-to-right order. Used for the default layout and to
    /// place any newly-introduced tool that an older persisted layout never
    /// recorded.
    static let canonicalOrder: [ToolbarItemID] = [
        .rectangle, .ellipse, .line, .arrow, .pen, .mosaic, .numbered, .text,
        .colorPicker, .undo, .redo, .moveSelection,
        .save, .pin, .close, .confirm, .settings, .share,
    ]

    /// wxShot's fixed layout: rectangle, ellipse, line, arrow, pen, mosaic,
    /// numbered, text | undo, redo, save, pin, share, close, confirm, settings.
    static var `default`: ToolbarLayout {
        ToolbarLayout(
            primary: [
                .rectangle, .ellipse, .line, .arrow, .pen, .mosaic, .numbered, .text,
                .undo, .redo, .save, .pin, .share, .close, .confirm, .settings,
            ],
            side: [],
            hidden: [
                .colorPicker, .moveSelection,
            ]
        )
    }

    /// Drops duplicate / unknown ids and slots any tool missing from all
    /// three buckets next to its canonical neighbour, so the result always
    /// covers every `ToolbarItemID` exactly once regardless of app-version
    /// drift. A newly-introduced tool lands beside its siblings (e.g. `line`
    /// after `ellipse`) instead of being dumped at the end of the bar.
    func normalized() -> ToolbarLayout {
        var seen = Set<ToolbarItemID>()
        func dedup(_ ids: [ToolbarItemID]) -> [ToolbarItemID] {
            ids.filter { seen.insert($0).inserted }
        }
        var p = dedup(primary)
        var s = dedup(side)
        var h = dedup(hidden)

        let missing = Self.canonicalOrder.filter { !seen.contains($0) }
        for item in missing {
            guard let canonicalIdx = Self.canonicalOrder.firstIndex(of: item) else { continue }
            // Walk back through the canonical order to the nearest sibling
            // that's already placed, then drop the new tool right after it
            // in whichever bucket that sibling lives in.
            var placed = false
            for prevIdx in stride(from: canonicalIdx - 1, through: 0, by: -1) {
                let prev = Self.canonicalOrder[prevIdx]
                if let i = p.firstIndex(of: prev) { p.insert(item, at: i + 1); placed = true; break }
                if let i = s.firstIndex(of: prev) { s.insert(item, at: i + 1); placed = true; break }
                if let i = h.firstIndex(of: prev) { h.insert(item, at: i + 1); placed = true; break }
            }
            if !placed { p.insert(item, at: 0) }
            seen.insert(item)
        }
        return ToolbarLayout(primary: p, side: s, hidden: h)
    }
}

extension ToolbarLayout {
    /// Builds a layout from a persisted `[bucket: [rawValue]]` dictionary,
    /// silently skipping any raw value no longer backed by a `ToolbarItemID`.
    init(dictionary: [String: [String]]) {
        func parse(_ key: String) -> [ToolbarItemID] {
            (dictionary[key] ?? []).compactMap(ToolbarItemID.init(rawValue:))
        }
        self.init(
            primary: parse("primary"),
            side: parse("side"),
            hidden: parse("hidden")
        )
    }

    /// Plain `[String: [String]]` form suitable for `UserDefaults`.
    var dictionary: [String: [String]] {
        [
            "primary": primary.map(\.rawValue),
            "side": side.map(\.rawValue),
            "hidden": hidden.map(\.rawValue),
        ]
    }
}

extension Defaults {
    /// wxShot ships one fixed toolbar that mirrors WeChat's, so there is nothing to persist.
    static var toolbarLayout: ToolbarLayout { .default }
}
