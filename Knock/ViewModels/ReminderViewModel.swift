import Foundation
import SwiftData
import SwiftUI

@MainActor
class ReminderViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var notificationEnabled = false

    let locationService = LocationService()
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Notification Permission

    func checkNotificationStatus() {
        Task {
            let status = await NotificationService.shared.checkPermission()
            notificationEnabled = status == .authorized
        }
    }

    func requestNotificationPermission() {
        Task {
            let granted = await NotificationService.shared.requestPermission()
            notificationEnabled = granted
        }
    }

    // MARK: - Submit Input via Gemini

    func submitInput() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let parsedReminders = try await GeminiService.shared.parseReminder(input: text)
                for parsed in parsedReminders {
                    let triggerDate = parseDate(from: parsed.triggerAt)
                    let reminder = Reminder(
                        title: parsed.title,
                        triggerAt: triggerDate,
                        repeatRule: parsed.repeatRule ?? "none",
                        intervalMinutes: parsed.intervalMinutes,
                        type: parsed.type ?? "custom"
                    )
                    addReminder(reminder)
                }
                inputText = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Quick Scenarios

    func handleQuickScenario(_ type: ReminderType) {
        if type == .prayer {
            handlePrayerScenario()
            return
        }

        let triggerAt: Date
        if let interval = type.defaultIntervalMinutes {
            triggerAt = Date().addingTimeInterval(TimeInterval(interval * 60))
        } else {
            triggerAt = Date().addingTimeInterval(3600)
        }

        let reminder = Reminder(
            title: type.defaultTitle,
            triggerAt: triggerAt,
            repeatRule: type.defaultRepeatRule,
            intervalMinutes: type.defaultIntervalMinutes,
            type: type.rawValue
        )

        addReminder(reminder)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func handlePrayerScenario() {
        Task {
            isLoading = true
            do {
                let location = try await locationService.requestLocation()
                let timings = try await PrayerService.shared.fetchPrayerTimes(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )

                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let calendar = Calendar.current
                let today = Date()

                for prayer in timings.allPrayers {
                    guard let time = timeFormatter.date(from: prayer.time) else { continue }
                    let components = calendar.dateComponents([.hour, .minute], from: time)
                    var triggerComponents = calendar.dateComponents([.year, .month, .day], from: today)
                    triggerComponents.hour = components.hour
                    triggerComponents.minute = components.minute
                    guard let triggerDate = calendar.date(from: triggerComponents) else { continue }
                    let finalDate = triggerDate < today
                        ? calendar.date(byAdding: .day, value: 1, to: triggerDate) ?? triggerDate
                        : triggerDate
                    let reminder = Reminder(
                        title: "\(prayer.name) Prayer",
                        triggerAt: finalDate,
                        repeatRule: "daily",
                        type: "prayer"
                    )
                    addReminder(reminder)
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - CRUD

    func addReminder(_ reminder: Reminder) {
        modelContext?.insert(reminder)
        try? modelContext?.save()
        if reminder.isActive {
            NotificationService.shared.scheduleNotification(for: reminder)
        }
    }

    func toggleReminder(_ reminder: Reminder) {
        reminder.isActive.toggle()
        try? modelContext?.save()
        if reminder.isActive {
            NotificationService.shared.scheduleNotification(for: reminder)
        } else {
            NotificationService.shared.cancelNotification(for: reminder.id)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func deleteReminder(_ reminder: Reminder) {
        NotificationService.shared.cancelNotification(for: reminder.id)
        modelContext?.delete(reminder)
        try? modelContext?.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func updateReminder(_ reminder: Reminder, title: String, triggerAt: Date, repeatRule: String, intervalMinutes: Int?) {
        NotificationService.shared.cancelNotification(for: reminder.id)
        reminder.title = title
        reminder.triggerAt = triggerAt
        reminder.repeatRule = repeatRule
        reminder.intervalMinutes = intervalMinutes
        try? modelContext?.save()
        if reminder.isActive {
            NotificationService.shared.scheduleNotification(for: reminder)
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Helpers

    private func parseDate(from string: String) -> Date {
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f1.date(from: string) { return d }

        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        if let d = f2.date(from: string) { return d }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = df.date(from: string) { return d }

        return Date().addingTimeInterval(3600)
    }
}
