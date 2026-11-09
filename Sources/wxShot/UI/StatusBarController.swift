import AppKit

/// Optional menu bar icon. It is hidden by default; wxShot is meant to live in the background and answer the shortcut.
final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let onTakeScreenshot: () -> Void
    private let onTakeFullScreenScreenshot: () -> Void
    private let onOpenSettings: () -> Void

    init(
        onTakeScreenshot: @escaping () -> Void,
        onTakeFullScreenScreenshot: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.onTakeScreenshot = onTakeScreenshot
        self.onTakeFullScreenScreenshot = onTakeFullScreenScreenshot
        self.onOpenSettings = onOpenSettings

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.isVisible = false

        super.init()

        if let button = statusItem.button {
            button.image = Self.statusBarIcon()
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
        }
        setupMenu()

        for name in [Notification.Name.languageDidChange, .hotkeyDidChange] {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.setupMenu()
            }
        }
    }

    func setMenuBarVisible(_ visible: Bool) {
        statusItem.isVisible = visible
    }

    private func setupMenu() {
        let menu = NSMenu()

        let screenshotItem = NSMenuItem(title: L10n.takeScreenshot, action: #selector(takeScreenshot), keyEquivalent: "")
        screenshotItem.target = self
        screenshotItem.image = Self.menuIcon(systemName: "crop")
        HotkeyManager.applyToMenuItem(screenshotItem)
        menu.addItem(screenshotItem)

        let fullScreenItem = NSMenuItem(title: L10n.takeFullScreenScreenshot, action: #selector(takeFullScreenScreenshot), keyEquivalent: "")
        fullScreenItem.target = self
        fullScreenItem.image = Self.menuIcon(systemName: "display")
        HotkeyManager.applyFullScreenScreenshotToMenuItem(fullScreenItem)
        menu.addItem(fullScreenItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: L10n.settings, action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.image = Self.menuIcon(systemName: "gearshape")
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: L10n.quitApp, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.image = Self.menuIcon(systemName: "power")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    fileprivate static func menuIcon(systemName: String) -> NSImage? {
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let image = NSImage(systemSymbolName: systemName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
        image?.isTemplate = true
        return image
    }

    private static func statusBarIcon() -> NSImage {
        let size = NSSize(width: 20, height: 20)
        let image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "wxShot") ?? NSImage(size: size)
        image.size = size
        image.isTemplate = true
        return image
    }

    @objc private func takeScreenshot() { onTakeScreenshot() }
    @objc private func takeFullScreenScreenshot() { onTakeFullScreenScreenshot() }
    @objc private func openSettings() { onOpenSettings() }
}
