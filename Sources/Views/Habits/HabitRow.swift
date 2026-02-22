import SwiftData
import SwiftUI

struct HabitRow: View {
  @Bindable var habit: Habit
  @Environment(\.modelContext) private var modelContext

  @State private var justCompleted = false

  private var isCompletedToday: Bool {
    habit.isCompleted(on: .now)
  }

  var body: some View {
    HStack(spacing: 14) {
      // Emoji
      Text(habit.emoji)
        .font(.title2)

      // Name + streak
      VStack(alignment: .leading, spacing: 3) {
        Text(habit.name)
          .font(.body.weight(.medium))
          .foregroundStyle(.primary)

        if habit.currentStreak > 0 {
          StreakBadge(count: habit.currentStreak)
        }
      }

      Spacer()

      // Completion toggle
      Button {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        toggleCompletion()
      } label: {
        Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
          .font(.title2)
          .foregroundStyle(isCompletedToday ? Color.green : Color.gray)
          .symbolEffect(.bounce, value: justCompleted)
      }
      .buttonStyle(.plain)
      .accessibilityLabel(isCompletedToday ? "Completed" : "Not completed")
    }
    .padding()
    .adaptiveGlass()
  }

  private func toggleCompletion() {
    let today = Calendar.current.startOfDay(for: .now)

    if let existingLog = habit.dailyLogs.first(where: {
      Calendar.current.isDate($0.date, inSameDayAs: today)
    }) {
      existingLog.toggle()
    } else {
      let log = DailyLog(habit: habit, date: today)
      log.isCompleted = true
      log.completedAt = .now
      modelContext.insert(log)
    }

    if isCompletedToday {
      justCompleted = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        justCompleted = false
      }
    }
  }
}
