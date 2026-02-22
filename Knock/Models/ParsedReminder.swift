import Foundation

struct ParsedReminder: Codable {
    let title: String
    let triggerAt: String // ISO 8601 or relative time string
    let repeatRule: String? // "none" | "daily" | "weekly"
    let intervalMinutes: Int?
    let type: String? // reminder type

    enum CodingKeys: String, CodingKey {
        case title
        case triggerAt = "trigger_at"
        case repeatRule = "repeat_rule"
        case intervalMinutes = "interval_minutes"
        case type
    }
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]

    struct Candidate: Codable {
        let content: Content
    }

    struct Content: Codable {
        let parts: [Part]
    }

    struct Part: Codable {
        let text: String?
    }
}
