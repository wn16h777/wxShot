import AppKit

enum EditorStyleDefaults {
    static let paletteColors: [NSColor] = [
        NSColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0),     // Red
        NSColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),      // Blue
        NSColor(red: 0.0, green: 0.83, blue: 0.42, alpha: 1.0),     // Green
        NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),       // Yellow
        NSColor(red: 0.843, green: 0.467, blue: 0.341, alpha: 1.0), // #D77757
        .white,
        NSColor(white: 0.5, alpha: 1.0),                           // Gray
        .black,
    ]

    static var primaryColor: NSColor {
        color(fromHex: Defaults.lastEditorColorHex) ?? paletteColors[0]
    }

    // Three size tiers per tool: index 0 = small, 1 = medium (default), 2 = large.
    static let lineWidthTiers: [CGFloat] = [2, 4, 8]
    static let numberSizeTiers: [CGFloat] = [3, 5, 8]
    static let mosaicSizeTiers: [CGFloat] = [6, 12, 24]
    static let mosaicBlurTiers: [CGFloat] = [4, 8, 16]
    static let fontSizeTiers: [CGFloat] = [14, 20, 30]

    static var standardLineWidth: CGFloat { lineWidthTiers[Defaults.lastLineWidthTier] }
    static var numberSize: CGFloat { numberSizeTiers[Defaults.lastNumberSizeTier] }

    private static func color(fromHex hex: String?) -> NSColor? {
        guard var trimmed = hex?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() else {
            return nil
        }
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        guard trimmed.count == 6, let value = UInt32(trimmed, radix: 16) else { return nil }
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        return NSColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
    }
}
