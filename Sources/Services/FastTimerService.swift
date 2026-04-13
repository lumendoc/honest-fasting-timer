import Foundation
import SwiftData
import WidgetKit

class FastTimerService: ObservableObject {
    @Published var activeFast: ActiveFast?
    @Published var currentTime = Date()
    
    private var timer: Timer?
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        // Load active fast from storage
        self.activeFast = AppGroupDefaults.shared.activeFast
        
        // Reschedule notification if there's an active fast (handles app restart)
        if let fast = self.activeFast, !fast.isComplete {
            NotificationService.shared.scheduleFastCompletionNotification(endDate: fast.endDate)
        }
        
        // Start UI update timer
        startTimer()
    }
    
    func setModelContext(_ context: ModelContext?) {
        self.modelContext = context
    }
    
    deinit {
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
            
            // Check if fast completed naturally
            if let fast = self?.activeFast, fast.isComplete {
                self?.completeFast()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startFast(preset: FastPreset, customDuration: TimeInterval? = nil) {
        let duration = preset == .custom ? (customDuration ?? 16 * 60 * 60) : preset.duration
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(duration)
        
        let fast = ActiveFast(
            startDate: startDate,
            endDate: endDate,
            presetName: preset.displayName,
            presetDuration: duration
        )
        
        self.activeFast = fast
        AppGroupDefaults.shared.activeFast = fast
        
        // Schedule notification
        NotificationService.shared.scheduleFastCompletionNotification(endDate: endDate)
        
        // Update widget
        WidgetCenter.shared.reloadTimelines(ofKind: "HonestFastingTimer")
    }
    
    func stopFast() {
        guard let fast = activeFast else { return }
        
        // Cancel notification
        NotificationService.shared.cancelFastCompletionNotification()
        
        // Save as completed fast (even if early)
        saveCompletedFast(fast, wasCompletedNaturally: false)
        
        // Clear active fast
        self.activeFast = nil
        AppGroupDefaults.shared.activeFast = nil
        
        // Update widget
        WidgetCenter.shared.reloadTimelines(ofKind: "HonestFastingTimer")
    }
    
    func completeFast() {
        guard let fast = activeFast else { return }
        
        // Cancel notification (though it should have fired)
        NotificationService.shared.cancelFastCompletionNotification()
        
        // Update streak BEFORE saving the new fast date (streak checks previous fast date)
        updateStreak()
        
        // Save as completed fast
        saveCompletedFast(fast, wasCompletedNaturally: true)
        
        // Clear active fast
        self.activeFast = nil
        AppGroupDefaults.shared.activeFast = nil
        
        // Update widget
        WidgetCenter.shared.reloadTimelines(ofKind: "HonestFastingTimer")
    }
    
    func extendFast(additionalTime: TimeInterval) {
        guard var fast = activeFast else { return }
        
        // Cancel existing notification
        NotificationService.shared.cancelFastCompletionNotification()
        
        // Extend end date
        let newEndDate = fast.endDate.addingTimeInterval(additionalTime)
        fast = ActiveFast(
            startDate: fast.startDate,
            endDate: newEndDate,
            presetName: fast.presetName,
            presetDuration: fast.presetDuration + additionalTime
        )
        
        self.activeFast = fast
        AppGroupDefaults.shared.activeFast = fast
        
        // Schedule new notification
        NotificationService.shared.scheduleFastCompletionNotification(endDate: newEndDate)
        
        // Update widget
        WidgetCenter.shared.reloadTimelines(ofKind: "HonestFastingTimer")
    }
    
    private func saveCompletedFast(_ fast: ActiveFast, wasCompletedNaturally: Bool) {
        // Save to SwiftData if context available
        if let context = modelContext {
            let completedFast = CompletedFast(
                startDate: fast.startDate,
                endDate: Date(),
                targetDuration: fast.presetDuration,
                presetName: fast.presetName,
                wasCompletedNaturally: wasCompletedNaturally
            )
            context.insert(completedFast)
            try? context.save()
        }
        
        // Update stats
        AppGroupDefaults.shared.totalCompletedFasts += 1
        AppGroupDefaults.shared.lastFastEndDate = Date()
    }
    
    private func updateStreak() {
        let defaults = AppGroupDefaults.shared
        
        // Check if last fast was within 24 hours
        if let lastEndDate = defaults.lastFastEndDate,
           Date().timeIntervalSince(lastEndDate) < 24 * 60 * 60 {
            defaults.currentStreak += 1
        } else {
            defaults.currentStreak = 1
        }
        
        // Update longest streak
        if defaults.currentStreak > defaults.longestStreak {
            defaults.longestStreak = defaults.currentStreak
        }
    }
}
