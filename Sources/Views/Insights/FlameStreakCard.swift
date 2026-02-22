import SwiftUI

/// Check-in streak card with fire animation when streak is active.
struct FlameStreakCard: View {
  let currentStreak: Int
  let longestStreak: Int

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    HStack(spacing: 16) {
      // Animated flame
      Image(systemName: "flame.fill")
        .font(.system(size: 36))
        .foregroundStyle(flameGradient)
        .shadow(
          color: currentStreak >= 1 ? .orange.opacity(0.4) : .clear,
          radius: currentStreak >= 7 ? 12 : 6
        )
        .scaleEffect(currentStreak >= 1 ? 1.0 : 0.8)
        .animation(
          reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.5),
          value: currentStreak
        )

      VStack(alignment: .leading, spacing: 4) {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text("\(currentStreak)")
            .font(.title.weight(.bold))
            .foregroundStyle(.primary)
            .contentTransition(.numericText())
          Text(currentStreak == 1 ? "day" : "days")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Text("Check-in streak")
          .font(.caption)
          .foregroundStyle(.tertiary)
      }

      Spacer()

      // Longest streak
      VStack(alignment: .trailing, spacing: 2) {
        Text("\(longestStreak)")
          .font(.headline.weight(.bold))
          .foregroundStyle(.secondary)
        Text("Longest")
          .font(.caption2)
          .foregroundStyle(.tertiary)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "\(currentStreak) day check-in streak. Longest streak: \(longestStreak) days."
    )
  }

  private var flameGradient: LinearGradient {
    if currentStreak >= 7 {
      return LinearGradient(
        colors: [.yellow, .orange, .red],
        startPoint: .top,
        endPoint: .bottom
      )
    } else if currentStreak >= 1 {
      return LinearGradient(
        colors: [.orange, .red],
        startPoint: .top,
        endPoint: .bottom
      )
    } else {
      return LinearGradient(
        colors: [Color.gray, Color.gray.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
      )
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    FlameStreakCard(currentStreak: 12, longestStreak: 28)
    FlameStreakCard(currentStreak: 3, longestStreak: 12)
    FlameStreakCard(currentStreak: 0, longestStreak: 5)
  }
  .padding()
}
