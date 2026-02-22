import SwiftUI
import SwiftData

@main
struct KnockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Reminder.self)
    }
}
