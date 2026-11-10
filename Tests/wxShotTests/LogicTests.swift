import XCTest
@testable import wxShot

final class LogicTests: XCTestCase {
    func testWeChatOwnership() {
        let monitor = WeChatMonitor.shared
        // State is machine dependent, so only check the fixed rule:
        // logged-in WeChat owns the shortcut, everything else is ours.
        let owns = monitor.shouldOwnShortcut()
        switch monitor.state {
        case .loggedIn: XCTAssertFalse(owns)
        case .notRunning, .loginScreen: XCTAssertTrue(owns)
        }
    }

    func testDefaultShortcutMatchesWeChatMac() {
        let hk = HotkeyManager.defaultHotkey
        XCTAssertEqual(HotkeyManager.modifierString(hk.modifiers) + HotkeyManager.keyString(hk.keyCode), "⌃⌘A")
    }
}
