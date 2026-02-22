import Foundation
import CoreLocation

class PrayerService {
    static let shared = PrayerService()

    private init() {}

    func fetchPrayerTimes(latitude: Double, longitude: Double) async throws -> PrayerTimings {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: Date())

        let urlString = "https://api.aladhan.com/v1/timings/\(dateString)?latitude=\(latitude)&longitude=\(longitude)&method=2"
        guard let url = URL(string: urlString) else {
            throw PrayerError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw PrayerError.apiError
        }

        let prayerResponse = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)
        return prayerResponse.data.timings
    }
}

enum PrayerError: LocalizedError {
    case invalidURL
    case apiError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid prayer times API URL"
        case .apiError:
            return "Failed to fetch prayer times"
        }
    }
}
