import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.3))

            Text("No reminders yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)

            Text("Type a reminder or use quick scenarios")
                .font(.system(size: 13))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}
