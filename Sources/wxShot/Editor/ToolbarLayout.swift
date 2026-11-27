import AppKit

/// Stable identifier for every button on the editor's toolbar. Raw values
/// surface as the buttons' accessibility identifiers, so existing cases must
/// never be renamed — only added or deprecated.
enum ToolbarItemID: String {
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
    case undo
    case redo
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
    }

    var kind: Kind {
        switch self {
        case .rectangle, .ellipse, .arrow, .line, .pen, .mosaic, .numbered, .text:
            return .toggleTool
        case .undo, .redo, .save, .pin, .close, .confirm, .settings, .share:
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
        case .undo:          return "arrow.uturn.backward"
        case .redo:          return "arrow.uturn.forward"
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
        case .undo:          return L10n.tipUndo
        case .redo:          return L10n.tipRedo
        case .save:          return L10n.tipSave
        case .pin:           return L10n.tipPin
        case .close:         return L10n.tipCancel
        case .confirm:       return L10n.tipConfirm
        case .settings:      return L10n.wxTipSettings
        case .share:         return L10n.wxTipShare
        }
    }

    /// Localized hover-tooltip text.
    var tooltip: String {
        localizedTitle
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
        case .momentary:
            return normalColor
        }
    }
}

/// Red used for the cancel button's icon. Mirrors the literal previously
/// inlined in `ToolbarView.setupButtons()`.
let toolbarDangerRed = NSColor(srgbRed: 0.89, green: 0.35, blue: 0.32, alpha: 1)
let toolbarConfirmGreen = NSColor(srgbRed: 0.24, green: 0.72, blue: 0.42, alpha: 1)
let toolbarIconGray = NSColor(srgbRed: 0.353, green: 0.353, blue: 0.353, alpha: 1)

/// wxShot's one and only toolbar, left to right: rectangle, ellipse, line,
/// arrow, pen, mosaic, numbered, text | undo, redo, save, pin, share, close,
/// confirm | settings.
enum ToolbarLayout {
    static let items: [ToolbarItemID] = [
        .rectangle, .ellipse, .line, .arrow, .pen, .mosaic, .numbered, .text,
        .undo, .redo, .save, .pin, .share, .close, .confirm, .settings,
    ]
}
