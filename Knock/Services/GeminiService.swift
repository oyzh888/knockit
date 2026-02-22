import Foundation

class GeminiService {
    static let shared = GeminiService()

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    private init() {}

    func parseReminder(input: String) async throws -> [ParsedReminder] {
        let apiKey = APIKeys.geminiAPIKey
        guard apiKey != "YOUR_GEMINI_API_KEY_HERE" else {
            throw GeminiError.noAPIKey
        }

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }

        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let currentTime = formatter.string(from: now)

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        let weekday = weekdayFormatter.string(from: now)

        let prompt = """
        You are a reminder parsing assistant. Parse the user's natural language input into structured reminder data.

        Current time: \(currentTime)
        Current day: \(weekday)

        User input: "\(input)"

        Return a JSON array of reminder objects. Each object should have:
        - "title": A clear, concise title for the reminder
        - "trigger_at": ISO 8601 datetime string for when the reminder should trigger
        - "repeat_rule": "none", "daily", or "weekly"
        - "interval_minutes": null or number of minutes for repeating interval reminders
        - "type": one of "custom", "prayer", "medicine", "water", "baby", "exercise", "sleep"

        Rules:
        - If the user says "every X minutes/hours", set interval_minutes accordingly
        - If the user mentions a specific time, calculate the trigger_at based on current time
        - If relative time like "in 30 minutes", calculate from current time
        - For "every day at X", set repeat_rule to "daily"
        - Default type to "custom" unless clearly matching another category
        - Always return an array, even for single reminders
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "responseSchema": [
                    "type": "ARRAY",
                    "items": [
                        "type": "OBJECT",
                        "properties": [
                            "title": ["type": "STRING"],
                            "trigger_at": ["type": "STRING"],
                            "repeat_rule": ["type": "STRING"],
                            "interval_minutes": ["type": "INTEGER"],
                            "type": ["type": "STRING"]
                        ],
                        "required": ["title", "trigger_at"]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let bodyStr = String(data: data, encoding: .utf8) ?? "no body"
            throw GeminiError.apiError(statusCode: statusCode, message: bodyStr)
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let text = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw GeminiError.noContent
        }

        guard let jsonData = text.data(using: .utf8) else {
            throw GeminiError.invalidJSON
        }

        let parsedReminders = try JSONDecoder().decode([ParsedReminder].self, from: jsonData)
        return parsedReminders
    }
}

enum GeminiError: LocalizedError {
    case noAPIKey
    case invalidURL
    case apiError(statusCode: Int, message: String)
    case noContent
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Please set your Gemini API key in APIKeys.swift"
        case .invalidURL:
            return "Invalid API URL"
        case .apiError(let code, let message):
            return "API error (\(code)): \(message)"
        case .noContent:
            return "No content in response"
        case .invalidJSON:
            return "Failed to parse response JSON"
        }
    }
}
