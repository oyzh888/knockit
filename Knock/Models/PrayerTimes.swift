import Foundation

struct PrayerTimesResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: PrayerTimings
    let date: PrayerDate
}

struct PrayerTimings: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String

    var allPrayers: [(name: String, time: String)] {
        [
            ("Fajr", Fajr),
            ("Dhuhr", Dhuhr),
            ("Asr", Asr),
            ("Maghrib", Maghrib),
            ("Isha", Isha)
        ]
    }
}

struct PrayerDate: Codable {
    let readable: String
    let timestamp: String
}
