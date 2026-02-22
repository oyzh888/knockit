import Foundation
import SwiftData

@Model
class Reminder: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var triggerAt: Date
    var repeatRule: String // "none" | "daily" | "weekly"
    var intervalMinutes: Int?
    var createdAt: Date
    var isActive: Bool
    var type: String // "custom"|"prayer"|"medicine"|"water"|"baby"|"exercise"|"sleep"

    init(
        id: String = UUID().uuidString,
        title: String,
        triggerAt: Date,
        repeatRule: String = "none",
        intervalMinutes: Int? = nil,
        createdAt: Date = Date(),
        isActive: Bool = true,
        type: String = "custom"
    ) {
        self.id = id
        self.title = title
        self.triggerAt = triggerAt
        self.repeatRule = repeatRule
        self.intervalMinutes = intervalMinutes
        self.createdAt = createdAt
        self.isActive = isActive
        self.type = type
    }

    var reminderType: ReminderType {
        ReminderType(rawValue: type) ?? .custom
    }
}
