import SwiftData
import SwiftUI

struct HabitProgressCard: View {
  let habits: [Habit]

  private var todayCompleted: Int {
    habits.filter { $0.isCompleted(on: .now) }.count
  }

  private var todayTotal: Int {
    let weekday = Calendar.current.component(.weekday, from: .now)
    return habits.filter { $0.frequency.isActiveOn(weekday: weekday) }.count
  }

  private var progress: Double {
    guard todayTotal > 0 else { return 0 }
    return Double(todayCompleted) / Double(todayTotal)
  }

  var body: some View {
    GlassCard {
      VStack(spacing: 16) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Today's Habits")
              .font(.headline.weight(.semibold))
              .foregroundStyle(.primary)

            Text("\(todayCompleted) of \(todayTotal) completed")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }

          Spacer()

          CircularProgress(
            progress: progress,
            lineWidth: 6,
            size: 64,
            label: "\(Int(progress * 100))%"
          )
        }

        if !habits.isEmpty {
          // Quick preview of uncompleted habits
          let uncompleted = habits.filter { !$0.isCompleted(on: .now) }.prefix(3)
          if !uncompleted.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              ForEach(Array(uncompleted)) { habit in
                HStack(spacing: 8) {
                  Text(habit.emoji)
                    .font(.caption)
                  Text(habit.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }
  }
}
