import SwiftUI

struct ReminderEditSheet: View {
    let reminder: Reminder
    let onSave: (String, Date, String, Int?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var triggerAt: Date
    @State private var repeatRule: String
    @State private var intervalEnabled: Bool
    @State private var intervalMinutes: Int

    init(reminder: Reminder, onSave: @escaping (String, Date, String, Int?) -> Void) {
        self.reminder = reminder
        self.onSave = onSave
        _title = State(initialValue: reminder.title)
        _triggerAt = State(initialValue: reminder.triggerAt)
        _repeatRule = State(initialValue: reminder.repeatRule)
        _intervalEnabled = State(initialValue: reminder.intervalMinutes != nil && reminder.intervalMinutes! > 0)
        _intervalMinutes = State(initialValue: reminder.intervalMinutes ?? 60)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Reminder title", text: $title)
                        .font(.system(size: 16))
                }

                Section("Time") {
                    DatePicker("Trigger at", selection: $triggerAt)
                        .datePickerStyle(.compact)
                }

                Section("Repeat") {
                    Picker("Repeat", selection: $repeatRule) {
                        Text("None").tag("none")
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                    }
                    .pickerStyle(.segmented)

                    Toggle("Interval repeat", isOn: $intervalEnabled)

                    if intervalEnabled {
                        Stepper(
                            "Every \(intervalMinutes) min",
                            value: $intervalMinutes,
                            in: 5...480,
                            step: 5
                        )
                    }
                }
            }
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let interval: Int? = intervalEnabled ? intervalMinutes : nil
                        onSave(title, triggerAt, repeatRule, interval)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
