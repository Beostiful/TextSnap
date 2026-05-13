import AppKit

// AppKit's main runloop is the main thread. Hop onto MainActor to bring up the app.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
