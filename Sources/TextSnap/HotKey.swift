import AppKit
import Carbon.HIToolbox

final class HotKey {
    private var ref: EventHotKeyRef?
    private let id: UInt32

    private static var handlers: [UInt32: () -> Void] = [:]
    private static var nextID: UInt32 = 1
    private static var installed = false
    private static let signature: OSType = 0x54534E50 // 'TSNP'

    init?(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        Self.installHandlerIfNeeded()

        self.id = Self.nextID
        Self.nextID += 1
        Self.handlers[self.id] = handler

        let hotKeyID = EventHotKeyID(signature: Self.signature, id: self.id)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode,
                                         modifiers,
                                         hotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &ref)
        if status != noErr {
            Self.handlers.removeValue(forKey: self.id)
            return nil
        }
        self.ref = ref
    }

    deinit {
        if let ref = ref { UnregisterEventHotKey(ref) }
        HotKey.handlers.removeValue(forKey: id)
    }

    private static func installHandlerIfNeeded() {
        guard !installed else { return }
        installed = true
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(),
                            { (_, event, _) -> OSStatus in
                                guard let event = event else { return noErr }
                                var hkID = EventHotKeyID()
                                let err = GetEventParameter(event,
                                                            EventParamName(kEventParamDirectObject),
                                                            EventParamType(typeEventHotKeyID),
                                                            nil,
                                                            MemoryLayout<EventHotKeyID>.size,
                                                            nil,
                                                            &hkID)
                                if err == noErr, let handler = HotKey.handlers[hkID.id] {
                                    DispatchQueue.main.async { handler() }
                                }
                                return noErr
                            },
                            1,
                            &spec,
                            nil,
                            nil)
    }
}
