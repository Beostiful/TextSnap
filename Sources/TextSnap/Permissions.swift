import AppKit
import CoreGraphics

enum Permissions {
    /// True when Screen Recording permission has been granted to this app.
    /// Returns false if the user hasn't granted yet — also implicitly triggers
    /// the system to register this app in Privacy & Security so the user can
    /// find the toggle there.
    static func hasScreenRecording() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    /// Asks the system to register us as needing Screen Recording so the toggle
    /// appears in Settings. This does NOT actually grant — the user must flip
    /// the switch themselves in System Settings.
    @discardableResult
    static func requestScreenRecording() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    /// Open System Settings directly to the Screen Recording pane.
    static func openScreenRecordingSettings() {
        let url = URL(string:
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        NSWorkspace.shared.open(url)
    }
}
