import SwiftUI

struct ReminderInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Remind me to...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary.opacity(0.55))
                        .allowsHitTesting(false)
                        .padding(.top, 1)
                }
                TextField("", text: $text, axis: .vertical)
                    .font(.system(size: 16))
                    .lineLimit(1...8)
                    .focused($isFocused)
                    .onSubmit(onSubmit)
            }
            .padding(.leading, 16)
            .padding(.trailing, 6)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)

            Button(action: onSubmit) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 34, height: 34)
                } else {
                    ZStack {
                        Circle()
                            .fill(text.isEmpty ? Color.secondary.opacity(0.12) : Color.emerald)
                            .frame(width: 34, height: 34)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(text.isEmpty ? .secondary.opacity(0.35) : .white)
                    }
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .disabled(text.isEmpty || isLoading)
            .buttonStyle(.plain)
            .padding(.trailing, 4)
            .padding(.bottom, 5)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .primary.opacity(0.06), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
        .onTapGesture { isFocused = true }
    }
}

