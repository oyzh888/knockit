import SwiftUI
import SwiftData

struct ReminderListView: View {
    let reminders: [Reminder]
    let onToggle: (Reminder) -> Void
    let onDelete: (Reminder) -> Void
    let onEdit: (Reminder) -> Void

    private var activeCount: Int {
        reminders.filter { $0.isActive }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text("ACTIVE REMINDERS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(1)

                Spacer()

                Text("\(activeCount) ACTIVE")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            if reminders.isEmpty {
                EmptyStateView()
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(reminders.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) { reminder in
                        ReminderRowView(
                            reminder: reminder,
                            onToggle: { onToggle(reminder) },
                            onDelete: { onDelete(reminder) },
                            onEdit: { onEdit(reminder) }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .slide.combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.3), value: reminders.count)
            }
        }
    }
}
