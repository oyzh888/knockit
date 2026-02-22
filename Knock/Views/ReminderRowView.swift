import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    @State private var now = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, HH:mm"
        return formatter.string(from: reminder.triggerAt)
    }

    private var countdownText: String? {
        guard reminder.isActive else { return nil }

        let target: Date
        if reminder.triggerAt > now {
            target = reminder.triggerAt
        } else if reminder.repeatRule == "daily" {
            let cal = Calendar.current
            let comps = cal.dateComponents([.hour, .minute], from: reminder.triggerAt)
            var next = cal.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: now) ?? now
            if next <= now { next = cal.date(byAdding: .day, value: 1, to: next) ?? now }
            target = next
        } else if let interval = reminder.intervalMinutes, interval > 0 {
            let elapsed = now.timeIntervalSince(reminder.triggerAt)
            let intervalSec = Double(interval * 60)
            let nextTick = reminder.triggerAt.addingTimeInterval(ceil(elapsed / intervalSec) * intervalSec)
            target = nextTick > now ? nextTick : now
        } else {
            return nil
        }

        let diff = target.timeIntervalSince(now)
        guard diff > 0 else { return "now" }

        let totalMin = Int(diff) / 60
        if totalMin < 1 { return "< 1m" }
        if totalMin < 60 { return "in \(totalMin)m" }
        let hours = totalMin / 60
        let mins = totalMin % 60
        if hours < 24 {
            return mins > 0 ? "in \(hours)h \(mins)m" : "in \(hours)h"
        }
        let days = hours / 24
        return "in \(days)d"
    }

    private var repeatBadge: String? {
        if let interval = reminder.intervalMinutes, interval > 0 {
            return "Every \(interval)min"
        }
        switch reminder.repeatRule {
        case "daily": return "Daily"
        case "weekly": return "Weekly"
        default: return nil
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Toggle circle
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(reminder.isActive ? Color.emerald : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: reminder.isActive ? "checkmark" : "")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            // Title and time — tappable for edit
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(reminder.isActive ? .primary : .secondary)
                    .strikethrough(!reminder.isActive)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text(timeString)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    if let countdown = countdownText {
                        Text(countdown)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(countdown == "now" || countdown == "< 1m" ? .orange : .emerald)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                (countdown == "now" || countdown == "< 1m" ? Color.orange : Color.emerald)
                                    .opacity(0.1)
                            )
                            .cornerRadius(4)
                    }

                    if let badge = repeatBadge {
                        Text(badge)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.emerald)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.emerald.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onEdit)

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.06), radius: 6, x: 0, y: 2)
        .onReceive(timer) { _ in
            now = Date()
        }
        .onAppear { now = Date() }
    }
}
