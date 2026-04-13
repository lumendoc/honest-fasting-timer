import Foundation

class AppGroupDefaults {
    static let shared = AppGroupDefaults()
    
    private let defaults: UserDefaults?
    
    private init() {
        defaults = UserDefaults(suiteName: AppConfig.appGroupId)
    }
    
    // MARK: - Active Fast
    
    var activeFast: ActiveFast? {
        get {
            guard let data = defaults?.data(forKey: "activeFast"),
                  let fast = try? JSONDecoder().decode(ActiveFast.self, from: data) else {
                return nil
            }
            return fast
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                defaults?.set(data, forKey: "activeFast")
            } else {
                defaults?.removeObject(forKey: "activeFast")
            }
            // Notify widget to update
            WidgetCenter.shared.reloadTimelines(ofKind: "HonestFastingTimer")
        }
    }
    
    var hasActiveFast: Bool {
        activeFast != nil
    }
    
    // MARK: - Paywall Gating
    
    /// Tracks if user has started their first fast ever (used for first-fast paywall gating)
    var hasStartedFirstFast: Bool {
        get { defaults?.bool(forKey: "hasStartedFirstFast") ?? false }
        set { defaults?.set(newValue, forKey: "hasStartedFirstFast") }
    }
    
    /// Tracks if user has seen the paywall (used to ensure consistent behavior)
    var hasSeenPaywall: Bool {
        get { defaults?.bool(forKey: "hasSeenPaywall") ?? false }
        set { defaults?.set(newValue, forKey: "hasSeenPaywall") }
    }
    
    // MARK: - User Preferences
    
    var selectedPreset: String {
        get { defaults?.string(forKey: "selectedPreset") ?? FastPreset.sixteenEight.rawValue }
        set { defaults?.set(newValue, forKey: "selectedPreset") }
    }
    
    var customDuration: TimeInterval {
        get { defaults?.double(forKey: "customDuration") ?? 16 * 60 * 60 }
        set { defaults?.set(newValue, forKey: "customDuration") }
    }
    
    // MARK: - Statistics
    
    var totalCompletedFasts: Int {
        get { defaults?.integer(forKey: "totalCompletedFasts") ?? 0 }
        set { defaults?.set(newValue, forKey: "totalCompletedFasts") }
    }
    
    var currentStreak: Int {
        get { defaults?.integer(forKey: "currentStreak") ?? 0 }
        set { defaults?.set(newValue, forKey: "currentStreak") }
    }
    
    var longestStreak: Int {
        get { defaults?.integer(forKey: "longestStreak") ?? 0 }
        set { defaults?.set(newValue, forKey: "longestStreak") }
    }
    
    var lastFastEndDate: Date? {
        get { defaults?.object(forKey: "lastFastEndDate") as? Date }
        set { defaults?.set(newValue, forKey: "lastFastEndDate") }
    }
}

import WidgetKit
