import AppKit

enum Capture {
    /// Launches the system area-selection UI (same as ⌘⇧4) and returns the captured CGImage,
    /// or nil if the user cancelled.
    static func selectArea(silent: Bool = true) async throws -> CGImage? {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("textsnap-\(UUID().uuidString).png")

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        // -i interactive area selection, -x silent, -o no window shadow
        var args = ["-i", "-o", tempURL.path]
        if silent { args.insert("-x", at: 1) }
        task.arguments = args

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            task.terminationHandler = { _ in
                continuation.resume()
            }
            do {
                try task.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }

        defer { try? FileManager.default.removeItem(at: tempURL) }

        guard FileManager.default.fileExists(atPath: tempURL.path) else {
            return nil // user cancelled
        }
        guard let nsImage = NSImage(contentsOf: tempURL),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return nil
        }
        return cgImage
    }
}
