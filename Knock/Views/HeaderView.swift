import SwiftUI

struct HeaderView: View {
    let notificationEnabled: Bool
    let onEnableNotifications: () -> Void

    var body: some View {
        HStack {
            // Bell icon + "Knock" title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.emerald)
                        .frame(width: 44, height: 44)

                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                Text("Knockit")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(.primary)
            }

            Spacer()

            // Enable Notifications button
            if !notificationEnabled {
                Button(action: onEnableNotifications) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                        Text("Enable Notifications")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.emerald)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
