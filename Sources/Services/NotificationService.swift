import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        print("Notification permission: \(granted)")
    }
    
    func checkAuthorizationStatus() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    func scheduleFastCompletionNotification(endDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Fast Complete! 🎉"
        content.body = "Your fasting period is over. Time to eat!"
        content.sound = .default
        content.badge = 1
        
        let timeInterval = endDate.timeIntervalSinceNow
        guard timeInterval > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "fast-completion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Scheduled fast completion notification for \(endDate)")
            }
        }
    }
    
    func cancelFastCompletionNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["fast-completion"])
        print("Cancelled fast completion notification")
    }
    
    func scheduleEatingWindowEndingNotification(endDate: Date) {
        // Optional: 30 min warning before next fast could start
        let content = UNMutableNotificationContent()
        content.title = "Eating Window Closing Soon"
        content.body = "Your eating window ends in 30 minutes."
        content.sound = .default
        
        let timeInterval = endDate.timeIntervalSinceNow + (30 * 60) // 30 min after fast ends
        guard timeInterval > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "eating-window-ending", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
