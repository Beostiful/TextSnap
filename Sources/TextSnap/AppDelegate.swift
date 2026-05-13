import AppKit
import Carbon.HIToolbox

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var resultWindow: ResultWindowController?
    private var settingsWindow: SettingsWindowController?
    private var hotKey: HotKey?
    private var isCapturing = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder",
                                   accessibilityDescription: "TextSnap")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()

        let captureItem = NSMenuItem(title: "Capture & Recognize Text",
                                     action: #selector(capture),
                                     keyEquivalent: "2")
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        captureItem.target = self
        menu.addItem(captureItem)

        let showItem = NSMenuItem(title: "Show Last Result",
                                  action: #selector(showLast),
                                  keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…",
                                      action: #selector(openSettings),
                                      keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let aboutItem = NSMenuItem(title: "About TextSnap",
                                   action: #selector(about),
                                   keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem(title: "Quit TextSnap",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))

        item.menu = menu
        self.statusItem = item

        // Global hotkey: ⌘⇧2
        self.hotKey = HotKey(keyCode: UInt32(kVK_ANSI_2),
                             modifiers: UInt32(cmdKey | shiftKey)) { [weak self] in
            Task { @MainActor in self?.capture() }
        }
    }

    @objc func capture() {
        guard !isCapturing else { return }

        if !Permissions.hasScreenRecording() {
            showPermissionDialog()
            return
        }

        isCapturing = true
        Task { @MainActor in
            defer { self.isCapturing = false }
            do {
                let playSound = Settings.shared.playSound
                guard let image = try await Capture.selectArea(silent: !playSound) else { return }
                let text = try await OCR.recognize(image: image)
                let display = text.isEmpty ? "(No text detected)" : text

                if Settings.shared.autoCopy && !text.isEmpty {
                    copyToClipboard(text)
                }
                if Settings.shared.showWindow || text.isEmpty {
                    showResult(display)
                }
                if !text.isEmpty { flashStatusItem() }
            } catch {
                showResult("Error: \(error.localizedDescription)")
            }
        }
    }

    @objc func showLast() {
        resultWindow?.bringToFront()
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController()
        }
        settingsWindow?.show()
    }

    private func showPermissionDialog() {
        // Trigger the system registration once so TextSnap appears in the Settings pane.
        Permissions.requestScreenRecording()

        let alert = NSAlert()
        alert.messageText = "Screen Recording permission needed"
        alert.informativeText = """
        To capture and read text from the screen, TextSnap needs Screen Recording access.

        1. Click “Open Privacy Settings” below.
        2. In the list, turn on the switch next to TextSnap.
        3. Quit TextSnap (menu bar → Quit) and reopen it.

        macOS shows the system prompt without an “Allow” button — you must toggle it on manually in Settings.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Privacy Settings")
        alert.addButton(withTitle: "Quit TextSnap")
        alert.addButton(withTitle: "Cancel")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            Permissions.openScreenRecordingSettings()
        case .alertSecondButtonReturn:
            NSApp.terminate(nil)
        default:
            break
        }
    }

    @objc func about() {
        let alert = NSAlert()
        alert.messageText = "TextSnap"
        alert.informativeText = """
        Area screenshot → text recognition.

        Shortcut: ⌘⇧2
        Uses Apple Vision OCR with automatic language detection.
        Recognized text is copied to the clipboard automatically.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    private func showResult(_ text: String) {
        if resultWindow == nil {
            resultWindow = ResultWindowController()
        }
        resultWindow?.show(text: text)
    }

    private func copyToClipboard(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    private func flashStatusItem() {
        guard let button = statusItem.button else { return }
        let original = button.image
        button.image = NSImage(systemSymbolName: "checkmark.circle.fill",
                               accessibilityDescription: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            button.image = original
        }
    }
}
