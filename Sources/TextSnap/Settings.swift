import Foundation

enum SettingsKey {
    static let autoCopy = "autoCopyOnCapture"
    static let playSound = "playShutterSound"
    static let showWindow = "showResultWindow"
}

@MainActor
final class Settings {
    static let shared = Settings()

    private let defaults = UserDefaults.standard

    private init() {
        defaults.register(defaults: [
            SettingsKey.autoCopy: true,
            SettingsKey.playSound: false,
            SettingsKey.showWindow: true,
        ])
    }

    var autoCopy: Bool {
        get { defaults.bool(forKey: SettingsKey.autoCopy) }
        set { defaults.set(newValue, forKey: SettingsKey.autoCopy) }
    }

    var playSound: Bool {
        get { defaults.bool(forKey: SettingsKey.playSound) }
        set { defaults.set(newValue, forKey: SettingsKey.playSound) }
    }

    var showWindow: Bool {
        get { defaults.bool(forKey: SettingsKey.showWindow) }
        set { defaults.set(newValue, forKey: SettingsKey.showWindow) }
    }
}
