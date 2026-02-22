import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.createdAt, order: .reverse) private var reminders: [Reminder]
    @StateObject private var viewModel = ReminderViewModel()
    @State private var editingReminder: Reminder?

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }

            ScrollView {
                VStack(spacing: 24) {
                    HeaderView(
                        notificationEnabled: viewModel.notificationEnabled,
                        onEnableNotifications: viewModel.requestNotificationPermission
                    )

                    ReminderInputView(
                        text: $viewModel.inputText,
                        isLoading: viewModel.isLoading,
                        onSubmit: viewModel.submitInput
                    )

                    QuickScenariosView(
                        onScenarioTap: viewModel.handleQuickScenario
                    )

                    ReminderListView(
                        reminders: reminders,
                        onToggle: viewModel.toggleReminder,
                        onDelete: viewModel.deleteReminder,
                        onEdit: { editingReminder = $0 }
                    )

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)

            // Error toast
            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            viewModel.errorMessage = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.checkNotificationStatus()
        }
        .sheet(item: $editingReminder) { reminder in
            ReminderEditSheet(reminder: reminder) { title, triggerAt, repeatRule, interval in
                viewModel.updateReminder(reminder, title: title, triggerAt: triggerAt, repeatRule: repeatRule, intervalMinutes: interval)
            }
        }
    }
}
