import AppKit

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let window: NSWindow
    private var permissionStatusLabel: NSTextField?
    private var permissionButton: NSButton?

    override init() {
        let rect = NSRect(x: 0, y: 0, width: 480, height: 340)
        let w = NSWindow(
            contentRect: rect,
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        w.title = "TextSnap Settings"
        w.isReleasedWhenClosed = false
        w.center()
        self.window = w

        super.init()
        w.delegate = self
        buildUI()
    }

    private func buildUI() {
        guard let content = window.contentView else { return }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 22, left: 24, bottom: 22, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            stack.topAnchor.constraint(equalTo: content.topAnchor),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])

        // Heading
        let heading = NSTextField(labelWithString: "Capture")
        heading.font = .boldSystemFont(ofSize: 13)
        heading.textColor = .secondaryLabelColor
        stack.addArrangedSubview(heading)

        // Auto-copy
        let autoCopyCheck = makeCheckbox(
            title: "Copy recognized text to clipboard immediately",
            isOn: Settings.shared.autoCopy,
            action: #selector(toggleAutoCopy(_:))
        )
        stack.addArrangedSubview(autoCopyCheck)

        let autoCopyHint = NSTextField(labelWithString:
            "When on, captures go straight to your clipboard — no extra click.")
        autoCopyHint.font = .systemFont(ofSize: 11)
        autoCopyHint.textColor = .tertiaryLabelColor
        stack.addArrangedSubview(autoCopyHint)

        // Show result window
        let showWindowCheck = makeCheckbox(
            title: "Show result window after capture",
            isOn: Settings.shared.showWindow,
            action: #selector(toggleShowWindow(_:))
        )
        stack.addArrangedSubview(showWindowCheck)

        // Sound
        let soundCheck = makeCheckbox(
            title: "Play shutter sound on capture",
            isOn: Settings.shared.playSound,
            action: #selector(togglePlaySound(_:))
        )
        stack.addArrangedSubview(soundCheck)

        // Divider
        let divider = NSBox()
        divider.boxType = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(divider)
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 24),
            divider.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -24),
        ])

        // Permission section
        let permHeading = NSTextField(labelWithString: "Permission")
        permHeading.font = .boldSystemFont(ofSize: 13)
        permHeading.textColor = .secondaryLabelColor
        stack.addArrangedSubview(permHeading)

        let permRow = NSStackView()
        permRow.orientation = .horizontal
        permRow.spacing = 10
        permRow.alignment = .centerY

        let statusLabel = NSTextField(labelWithString: "")
        statusLabel.font = .systemFont(ofSize: 13)
        permRow.addArrangedSubview(statusLabel)
        self.permissionStatusLabel = statusLabel

        let openBtn = NSButton(title: "Open Privacy Settings",
                               target: self,
                               action: #selector(openPrivacySettings))
        openBtn.bezelStyle = .rounded
        openBtn.controlSize = .small
        permRow.addArrangedSubview(openBtn)
        self.permissionButton = openBtn

        stack.addArrangedSubview(permRow)

        let permHint = NSTextField(labelWithString:
            "After toggling TextSnap on, quit and reopen the app.")
        permHint.font = .systemFont(ofSize: 11)
        permHint.textColor = .tertiaryLabelColor
        stack.addArrangedSubview(permHint)

        // Spacer
        stack.addArrangedSubview(NSView())

        // Footer hint
        let footer = NSTextField(labelWithString: "Shortcut:  ⌘⇧2")
        footer.font = .systemFont(ofSize: 11)
        footer.textColor = .secondaryLabelColor
        stack.addArrangedSubview(footer)

        refreshPermissionStatus()
    }

    private func refreshPermissionStatus() {
        let granted = Permissions.hasScreenRecording()
        permissionStatusLabel?.stringValue = granted
            ? "Screen Recording: granted ✓"
            : "Screen Recording: not granted"
        permissionStatusLabel?.textColor = granted ? .systemGreen : .systemOrange
        permissionButton?.isHidden = granted
    }

    @objc private func openPrivacySettings() {
        Permissions.requestScreenRecording()
        Permissions.openScreenRecordingSettings()
    }

    private func makeCheckbox(title: String, isOn: Bool, action: Selector) -> NSButton {
        let b = NSButton(checkboxWithTitle: title, target: self, action: action)
        b.state = isOn ? .on : .off
        b.font = .systemFont(ofSize: 13)
        return b
    }

    func show() {
        refreshPermissionStatus()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func toggleAutoCopy(_ sender: NSButton) {
        Settings.shared.autoCopy = (sender.state == .on)
    }

    @objc private func toggleShowWindow(_ sender: NSButton) {
        Settings.shared.showWindow = (sender.state == .on)
    }

    @objc private func togglePlaySound(_ sender: NSButton) {
        Settings.shared.playSound = (sender.state == .on)
    }
}
