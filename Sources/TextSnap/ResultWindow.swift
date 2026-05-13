import AppKit

@MainActor
final class ResultWindowController: NSObject, NSWindowDelegate {
    private let window: NSWindow
    private let textView: NSTextView
    private let copyButton: NSButton
    private let statusLabel: NSTextField

    override init() {
        let rect = NSRect(x: 0, y: 0, width: 620, height: 420)
        let w = NSWindow(
            contentRect: rect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        w.title = "TextSnap"
        w.isReleasedWhenClosed = false
        w.center()
        w.minSize = NSSize(width: 360, height: 240)

        let content = NSView(frame: rect)
        content.autoresizingMask = [.width, .height]

        // Toolbar row
        let toolbarHeight: CGFloat = 40
        let toolbar = NSView(frame: NSRect(x: 0,
                                           y: rect.height - toolbarHeight,
                                           width: rect.width,
                                           height: toolbarHeight))
        toolbar.autoresizingMask = [.width, .minYMargin]

        let copyBtn = NSButton(title: "Copy", target: nil, action: nil)
        copyBtn.bezelStyle = .rounded
        copyBtn.frame = NSRect(x: rect.width - 84, y: 6, width: 72, height: 28)
        copyBtn.autoresizingMask = [.minXMargin]
        toolbar.addSubview(copyBtn)

        let status = NSTextField(labelWithString: "")
        status.frame = NSRect(x: 12, y: 10, width: rect.width - 110, height: 20)
        status.autoresizingMask = [.width]
        status.textColor = .secondaryLabelColor
        status.font = .systemFont(ofSize: 12)
        toolbar.addSubview(status)

        content.addSubview(toolbar)

        // Text view in scroll view
        let scrollFrame = NSRect(x: 0, y: 0, width: rect.width, height: rect.height - toolbarHeight)
        let scroll = NSScrollView(frame: scrollFrame)
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.borderType = .noBorder
        scroll.drawsBackground = false

        let tv = NSTextView(frame: scroll.bounds)
        tv.autoresizingMask = [.width]
        tv.isEditable = true
        tv.isRichText = false
        tv.allowsUndo = true
        tv.font = .systemFont(ofSize: 14)
        tv.textContainerInset = NSSize(width: 18, height: 14)
        tv.minSize = NSSize(width: 0, height: 0)
        tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                            height: CGFloat.greatestFiniteMagnitude)
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.textContainer?.widthTracksTextView = true
        scroll.documentView = tv
        content.addSubview(scroll)

        w.contentView = content

        self.window = w
        self.textView = tv
        self.copyButton = copyBtn
        self.statusLabel = status

        super.init()

        w.delegate = self
        copyBtn.target = self
        copyBtn.action = #selector(copyAll)
    }

    func show(text: String) {
        textView.string = text
        statusLabel.stringValue = text.isEmpty
            ? ""
            : "Copied to clipboard · \(text.count) chars"
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func bringToFront() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func copyAll() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(textView.string, forType: .string)
        statusLabel.stringValue = "Copied · \(textView.string.count) chars"
    }
}
