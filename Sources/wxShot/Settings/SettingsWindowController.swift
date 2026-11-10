import AppKit
import PermissionFlow

/// The whole settings surface: one short page, no tabs.
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsWindowController()

    var onMenuBarToggle: ((Bool) -> Void)?

    private let recorder = ShortcutRecorderView()
    private let weChatStatusLabel = NSTextField(labelWithString: "")
    private let ownerLabel = NSTextField(labelWithString: "")
    private let permissionLabel = NSTextField(labelWithString: "")
    private let permissionButton = NSButton()
    private let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
    private let menuBarCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
    private let languagePopup = NSPopUpButton()
    private var refreshTimer: Timer?

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 560),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        buildContent()
        refreshAll()

        NotificationCenter.default.addObserver(forName: .weChatStateDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.refreshWeChatSection()
        }
        NotificationCenter.default.addObserver(forName: .hotkeyDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.refreshWeChatSection()
        }
        NotificationCenter.default.addObserver(forName: .languageDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.buildContent()
            self?.refreshAll()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func showAsSettings() {
        refreshAll()
        window?.center()
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        // The permission can change while the window is open; look again every couple of seconds.
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.refreshPermission()
            WeChatMonitor.shared.refresh()
        }
    }

    func windowWillClose(_ notification: Notification) {
        recorder.cancelRecording()
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - Building

    private func buildContent() {
        window?.title = L10n.wxSettingsWindowTitle

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)

        stack.addArrangedSubview(header())

        stack.addArrangedSubview(sectionTitle(L10n.wxSectionShortcut))
        stack.addArrangedSubview(recorder)
        stack.addArrangedSubview(note(L10n.wxShortcutDefaultNote))

        stack.addArrangedSubview(divider())
        stack.addArrangedSubview(sectionTitle(L10n.wxSectionWeChat))
        weChatStatusLabel.font = .systemFont(ofSize: 12)
        weChatStatusLabel.textColor = .secondaryLabelColor
        stack.addArrangedSubview(weChatStatusLabel)
        ownerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        stack.addArrangedSubview(ownerLabel)

        stack.addArrangedSubview(divider())
        stack.addArrangedSubview(sectionTitle(L10n.permissionsHeader))
        permissionLabel.font = .systemFont(ofSize: 13)
        permissionButton.title = L10n.wxOpenSystemSettings
        permissionButton.bezelStyle = .rounded
        permissionButton.target = self
        permissionButton.action = #selector(openPermissionSettings)
        let permissionRow = NSStackView(views: [permissionLabel, permissionButton])
        permissionRow.spacing = 12
        stack.addArrangedSubview(permissionRow)

        stack.addArrangedSubview(divider())
        stack.addArrangedSubview(sectionTitle(L10n.wxSectionGeneral))
        launchAtLoginCheckbox.title = L10n.launchAtLogin
        launchAtLoginCheckbox.target = self
        launchAtLoginCheckbox.action = #selector(launchAtLoginChanged)
        menuBarCheckbox.title = L10n.showMenuBarIcon
        menuBarCheckbox.target = self
        menuBarCheckbox.action = #selector(menuBarChanged)
        [launchAtLoginCheckbox, menuBarCheckbox].forEach(stack.addArrangedSubview)

        languagePopup.removeAllItems()
        for language in AppLanguage.allCases { languagePopup.addItem(withTitle: language.displayName) }
        languagePopup.target = self
        languagePopup.action = #selector(languageChanged)
        stack.addArrangedSubview(languagePopup)

        window?.contentView = stack
        // Let the window fit its content height.
        let fitting = stack.fittingSize
        window?.setContentSize(NSSize(width: 520, height: fitting.height))
    }

    private func header() -> NSView {
        let name = NSTextField(labelWithString: "wxShot")
        name.font = .systemFont(ofSize: 22, weight: .semibold)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let versionLabel = NSTextField(labelWithString: "v\(version)")
        versionLabel.textColor = .secondaryLabelColor
        let row = NSStackView(views: [name, versionLabel])
        row.alignment = .firstBaseline
        row.spacing = 8
        return row
    }

    private func sectionTitle(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }

    private func note(_ text: String) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabelColor
        label.preferredMaxLayoutWidth = 470
        return label
    }

    private func divider() -> NSBox {
        let box = NSBox()
        box.boxType = .separator
        box.translatesAutoresizingMaskIntoConstraints = false
        box.widthAnchor.constraint(equalToConstant: 472).isActive = true
        return box
    }

    // MARK: - Refresh

    private func refreshAll() {
        refreshWeChatSection()
        refreshPermission()
        launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
        menuBarCheckbox.state = Defaults.showMenuBar ? .on : .off
        if let index = AppLanguage.allCases.firstIndex(of: Defaults.language) { languagePopup.selectItem(at: index) }
    }

    private func refreshWeChatSection() {
        let state = WeChatMonitor.shared.state
        switch state {
        case .notRunning: weChatStatusLabel.stringValue = L10n.wxWeChatStatusNotRunning
        case .loginScreen: weChatStatusLabel.stringValue = L10n.wxWeChatStatusLoginScreen
        case .loggedIn: weChatStatusLabel.stringValue = L10n.wxWeChatStatusLoggedIn
        }
        let owner = WeChatMonitor.shared.shouldOwnShortcut() ? "wxShot" : L10n.wxOwnerWeChat
        ownerLabel.stringValue = L10n.wxShortcutOwner(owner)
    }

    private func refreshPermission() {
        let granted = AppPermissions.screenRecordingGranted
        permissionLabel.stringValue = (granted ? "✓ " : "⚠︎ ") + (granted ? L10n.wxPermissionStatusGranted : L10n.wxPermissionStatusMissing)
        permissionLabel.textColor = granted ? .labelColor : .systemOrange
        permissionButton.isHidden = granted
    }

    // MARK: - Actions

    @objc private func openPermissionSettings() {
        OnboardingWindowController.shared.show()
    }

    @objc private func launchAtLoginChanged() {
        let desired = launchAtLoginCheckbox.state == .on
        if !LaunchAtLogin.setEnabled(desired) {
            launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
        }
    }

    @objc private func menuBarChanged() {
        Defaults.showMenuBar = menuBarCheckbox.state == .on
        onMenuBarToggle?(Defaults.showMenuBar)
    }

    @objc private func languageChanged() {
        let index = languagePopup.indexOfSelectedItem
        guard AppLanguage.allCases.indices.contains(index) else { return }
        Defaults.language = AppLanguage.allCases[index]
    }
}
