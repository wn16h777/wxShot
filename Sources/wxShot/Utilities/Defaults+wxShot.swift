import Foundation

extension Defaults {
    static var weChatPolicy: WeChatPolicy {
        get { WeChatPolicy(rawValue: defaults.string(forKey: "weChatPolicy") ?? "") ?? .auto }
        set { defaults.set(newValue.rawValue, forKey: "weChatPolicy") }
    }

    static var onboardingCompleted: Bool {
        get { defaults.bool(forKey: "onboardingCompleted") }
        set { defaults.set(newValue, forKey: "onboardingCompleted") }
    }
}
