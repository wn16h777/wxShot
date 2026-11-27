import AppKit

enum AppPermissions {
    static var screenRecordingGranted: Bool {
        CGPreflightScreenCaptureAccess()
    }
}
