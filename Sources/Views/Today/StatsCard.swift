import SwiftUI

struct StatsCard: View {
  let habits: [Habit]
  let journalEntryCount: Int

  private var longestStreak: Int {
    habits.map(\.currentStreak).max() ?? 0
  }

  private var weeklyCompletions: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    var count = 0

    for habit in habits {
      for offset in 0..<7 {
        guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
          continue
        }
        if habit.isCompleted(on: date) {
          count += 1
        }
      }
    }

    return count
  }

  var body: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("This Week")
          .font(.headline.weight(.semibold))
          .foregroundStyle(.primary)

        HStack(spacing: 0) {
          StatItem(
            value: "\(longestStreak)",
            label: "Best Streak",
            systemImage: "flame.fill",
            color: .orange
          )

          StatItem(
            value: "\(weeklyCompletions)",
            label: "Completions",
            systemImage: "checkmark.circle.fill",
            color: .green
          )

          StatItem(
            value: "\(journalEntryCount)",
            label: "Entries",
            systemImage: "book.fill",
            color: .purple
          )
        }
      }
    }
  }
}

private struct StatItem: View {
  let value: String
  let label: String
  let systemImage: String
  let color: Color

  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: systemImage)
        .font(.title3)
        .foregroundStyle(color)

      Text(value)
        .font(.title2.weight(.bold))
        .foregroundStyle(.primary)
        .contentTransition(.numericText())

      Text(label)
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(label): \(value)")
  }
}
