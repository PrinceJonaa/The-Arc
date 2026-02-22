import Foundation
import SwiftData

@Model
final class DailyLog {
  var id: UUID
  var date: Date
  var isCompleted: Bool
  var completedAt: Date?

  var habit: Habit?

  init(habit: Habit, date: Date) {
    self.id = UUID()
    self.date = Calendar.current.startOfDay(for: date)
    self.isCompleted = false
    self.completedAt = nil
    self.habit = habit
  }

  func toggle() {
    isCompleted.toggle()
    completedAt = isCompleted ? .now : nil
  }
}
