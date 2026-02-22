import Foundation
import SwiftData

/// Frequency at which a habit should be completed.
enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
  case daily
  case weekdays
  case weekends

  var id: String { rawValue }

  var label: String {
    switch self {
    case .daily: "Every Day"
    case .weekdays: "Weekdays"
    case .weekends: "Weekends"
    }
  }

  /// Whether the given weekday (1 = Sunday … 7 = Saturday) is active.
  func isActiveOn(weekday: Int) -> Bool {
    switch self {
    case .daily:
      true
    case .weekdays:
      (2...6).contains(weekday)
    case .weekends:
      weekday == 1 || weekday == 7
    }
  }
}

@Model
final class Habit {
  var id: UUID
  var name: String
  var emoji: String
  var colorHex: String
  var frequency: HabitFrequency
  var createdAt: Date
  var isArchived: Bool

  @Relationship(deleteRule: .cascade, inverse: \DailyLog.habit)
  var dailyLogs: [DailyLog]

  init(
    name: String,
    emoji: String = "⭐",
    colorHex: String = "#007AFF",
    frequency: HabitFrequency = .daily
  ) {
    self.id = UUID()
    self.name = name
    self.emoji = emoji
    self.colorHex = colorHex
    self.frequency = frequency
    self.createdAt = .now
    self.isArchived = false
    self.dailyLogs = []
  }
}

// MARK: - Computed Helpers

extension Habit {
  /// Whether this habit was completed on a given date.
  func isCompleted(on date: Date) -> Bool {
    let calendar = Calendar.current
    return dailyLogs.contains { log in
      log.isCompleted && calendar.isDate(log.date, inSameDayAs: date)
    }
  }

  /// Current consecutive-day streak ending today (or yesterday).
  var currentStreak: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    var streak = 0
    var checkDate = today

    // If not completed today, start from yesterday
    if !isCompleted(on: today) {
      guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
        return 0
      }
      checkDate = yesterday
    }

    while isCompleted(on: checkDate) {
      streak += 1
      guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
        break
      }
      checkDate = previous
    }

    return streak
  }

  /// Completion rate over the last N days (0.0–1.0).
  func completionRate(days: Int = 7) -> Double {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    var activeDays = 0
    var completedDays = 0

    for offset in 0..<days {
      guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
        continue
      }
      let weekday = calendar.component(.weekday, from: date)
      if frequency.isActiveOn(weekday: weekday) {
        activeDays += 1
        if isCompleted(on: date) {
          completedDays += 1
        }
      }
    }

    guard activeDays > 0 else { return 0 }
    return Double(completedDays) / Double(activeDays)
  }
}
