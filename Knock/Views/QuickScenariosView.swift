import SwiftUI

struct QuickScenariosView: View {
    let onScenarioTap: (ReminderType) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK SCENARIOS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1)
                .padding(.horizontal, 20)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ReminderType.quickScenarios, id: \.rawValue) { type in
                    QuickScenarioButton(type: type) {
                        onScenarioTap(type)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct QuickScenarioButton: View {
    let type: ReminderType
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(type.backgroundColor)
                        .frame(width: 44, height: 44)

                    Image(systemName: type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(type.iconColor)
                }

                Text(type.displayName.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: .primary.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
