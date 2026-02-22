import SwiftUI

/// Horizontal mood selector with SF Symbols and colors.
struct MoodPicker: View {
  @Binding var selected: Mood

  var body: some View {
    HStack(spacing: 12) {
      ForEach(Mood.allCases) { mood in
        Button {
          let impact = UIImpactFeedbackGenerator(style: .light)
          impact.impactOccurred()
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selected = mood
          }
        } label: {
          VStack(spacing: 4) {
            Text(mood.emoji)
              .font(.title2)
              .scaleEffect(selected == mood ? 1.2 : 1.0)

            Text(mood.label)
              .font(.caption2.weight(.medium))
              .foregroundStyle(selected == mood ? .primary : .tertiary)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background {
            if selected == mood {
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(mood.color.opacity(0.15))
                .overlay {
                  RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(mood.color.opacity(0.3), lineWidth: 1)
                }
            }
          }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mood.label)
        .accessibilityAddTraits(selected == mood ? .isSelected : [])
      }
    }
  }
}

#Preview {
  struct Preview: View {
    @State var mood: Mood = .good
    var body: some View {
      MoodPicker(selected: $mood)
        .padding()
    }
  }
  return Preview()
}
