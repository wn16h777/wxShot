import XCTest
@testable import wxShot

final class LogicTests: XCTestCase {
    func testWeChatOwnership() {
        let monitor = WeChatMonitor.shared
        // State is machine dependent, so only check the pure policy table through a fresh evaluation of each policy.
        for policy in WeChatPolicy.allCases {
            let owns = monitor.shouldOwnShortcut(policy: policy)
            switch monitor.state {
            case .notRunning: XCTAssertTrue(owns)
            case .loginScreen: XCTAssertEqual(owns, policy != .yieldWhenRunning)
            case .loggedIn: XCTAssertEqual(owns, policy == .alwaysUs)
            }
        }
    }

    func testDefaultShortcutMatchesWeChatMac() {
        let hk = HotkeyManager.defaultHotkey
        XCTAssertEqual(HotkeyManager.modifierString(hk.modifiers) + HotkeyManager.keyString(hk.keyCode), "⌃⌘A")
    }
}
