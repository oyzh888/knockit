import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Knockit"
        content.body = reminder.title
        content.sound = .default
        content.userInfo = ["reminderId": reminder.id]

        let trigger: UNNotificationTrigger

        if let interval = reminder.intervalMinutes, interval > 0 {
            // Interval-based repeating (e.g., water every 60 min, feeding every 180 min)
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(interval * 60),
                repeats: true
            )
        } else if reminder.repeatRule == "daily" {
            // Daily repeat at specific time
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.triggerAt)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        } else if reminder.repeatRule == "weekly" {
            // Weekly repeat
            let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: reminder.triggerAt)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        } else {
            // One-time notification
            let timeInterval = reminder.triggerAt.timeIntervalSinceNow
            guard timeInterval > 0 else { return }
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        }

        let request = UNNotificationRequest(
            identifier: reminder.id,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelNotification(for reminderId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [reminderId])
        center.removeDeliveredNotifications(withIdentifiers: [reminderId])
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
