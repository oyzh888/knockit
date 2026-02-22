import SwiftUI

enum ReminderType: String, CaseIterable {
    case custom
    case baby
    case prayer
    case medicine
    case water
    case exercise
    case sleep

    var displayName: String {
        switch self {
        case .custom: return "Custom"
        case .baby: return "Feeding"
        case .prayer: return "Prayer"
        case .medicine: return "Medicine"
        case .water: return "Water"
        case .exercise: return "Exercise"
        case .sleep: return "Sleep"
        }
    }

    var icon: String {
        switch self {
        case .custom: return "bell.fill"
        case .baby: return "face.smiling.fill"
        case .prayer: return "safari.fill"
        case .medicine: return "pills.fill"
        case .water: return "drop.fill"
        case .exercise: return "waveform.path.ecg"
        case .sleep: return "moon.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .custom: return Color.gray.opacity(0.15)
        case .baby: return Color.orange.opacity(0.15)
        case .prayer: return Color.green.opacity(0.15)
        case .medicine: return Color.blue.opacity(0.15)
        case .water: return Color.cyan.opacity(0.15)
        case .exercise: return Color.pink.opacity(0.15)
        case .sleep: return Color.purple.opacity(0.15)
        }
    }

    var iconColor: Color {
        switch self {
        case .custom: return .gray
        case .baby: return .orange
        case .prayer: return .green
        case .medicine: return .blue
        case .water: return .cyan
        case .exercise: return .pink
        case .sleep: return .purple
        }
    }

    static var quickScenarios: [ReminderType] {
        [.baby, .prayer, .medicine, .water, .exercise, .sleep]
    }

    var defaultTitle: String {
        switch self {
        case .baby: return "Feeding Time"
        case .prayer: return "Prayer Time"
        case .medicine: return "Take Medicine"
        case .water: return "Drink Water"
        case .exercise: return "Exercise Time"
        case .sleep: return "Time to Sleep"
        case .custom: return "Reminder"
        }
    }

    var defaultIntervalMinutes: Int? {
        switch self {
        case .baby: return 180
        case .water: return 60
        case .medicine: return nil
        case .exercise: return nil
        case .sleep: return nil
        case .prayer: return nil
        case .custom: return nil
        }
    }

    var defaultRepeatRule: String {
        switch self {
        case .baby, .water: return "none" // uses intervalMinutes instead
        case .medicine: return "daily"
        case .exercise: return "daily"
        case .sleep: return "daily"
        case .prayer: return "daily"
        case .custom: return "none"
        }
    }
}
