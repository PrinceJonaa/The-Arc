import Foundation
import SwiftData

/// Pure analytics engine — computes insights from SwiftData models.
/// No UI dependencies. All methods are static for easy testing.
enum InsightsEngine {
  // MARK: - Flame Insights

  struct FlameSummary {
    let average: Double
    let trend: TrendDirection
    let currentStreak: Int
    let longestStreak: Int
    let bestDayOfWeek: String?
    let totalCheckIns: Int
  }

  enum TrendDirection: String {
    case up = "📈"
    case down = "📉"
    case flat = "📊"

    var label: String {
      switch self {
      case .up: "Trending up"
      case .down: "Dipping — but dips are normal"
      case .flat: "Holding steady"
      }
    }
  }

  static func flameSummary(from checkIns: [FlameCheckIn], days: Int = 30) -> FlameSummary {
    let calendar = Calendar.current
    let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
    let recent = checkIns.filter { $0.date >= cutoff }.sorted { $0.date < $1.date }

    let average: Double
    if recent.isEmpty {
      average = 0
    } else {
      average = Double(recent.reduce(0) { $0 + $1.score }) / Double(recent.count)
    }

    // Trend
    let trend: TrendDirection
    if recent.count < 5 {
      trend = .flat
    } else {
      let half = recent.count / 2
      let firstAvg = Double(recent.prefix(half).reduce(0) { $0 + $1.score }) / Double(half)
      let secondAvg = Double(recent.suffix(half).reduce(0) { $0 + $1.score }) / Double(half)
      if secondAvg > firstAvg + 0.5 {
        trend = .up
      } else if secondAvg < firstAvg - 0.5 {
        trend = .down
      } else {
        trend = .flat
      }
    }

    // Streaks
    let currentStreak = computeStreak(from: checkIns, fromEnd: true)
    let longestStreak = computeLongestStreak(from: checkIns)

    // Best day of week
    let bestDay = bestDayOfWeek(from: recent)

    return FlameSummary(
      average: average,
      trend: trend,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      bestDayOfWeek: bestDay,
      totalCheckIns: recent.count
    )
  }

  // MARK: - Mood Distribution

  struct MoodSlice: Identifiable {
    let mood: Mood
    let count: Int
    let percentage: Double
    var id: String { mood.rawValue }
  }

  static func moodDistribution(from entries: [JournalEntry], days: Int = 30) -> [MoodSlice] {
    let calendar = Calendar.current
    let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
    let recent = entries.filter { $0.date >= cutoff }

    guard !recent.isEmpty else { return [] }

    var counts: [Mood: Int] = [:]
    for entry in recent {
      counts[entry.mood, default: 0] += 1
    }

    let total = Double(recent.count)
    return counts.map { mood, count in
      MoodSlice(mood: mood, count: count, percentage: Double(count) / total)
    }
    .sorted { $0.count > $1.count }
  }

  // MARK: - Habit Insights

  struct HabitScore: Identifiable {
    let name: String
    let emoji: String
    let completionRate: Double
    let streak: Int
    var id: String { name }
  }

  static func habitScores(from habits: [Habit], days: Int = 30) -> [HabitScore] {
    habits
      .filter { !$0.isArchived }
      .map { habit in
        HabitScore(
          name: habit.name,
          emoji: habit.emoji,
          completionRate: habit.completionRate(days: days),
          streak: habit.currentStreak
        )
      }
      .sorted { $0.completionRate > $1.completionRate }
  }

  // MARK: - Journal Insights

  struct JournalSummary {
    let totalEntries: Int
    let voiceEntries: Int
    let writtenEntries: Int
    let mirrorEntries: Int
    let entriesPerWeek: Double
  }

  static func journalSummary(
    from entries: [JournalEntry],
    days: Int = 30
  ) -> JournalSummary {
    let calendar = Calendar.current
    let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
    let recent = entries.filter { $0.date >= cutoff }

    let voice = recent.filter { $0.promptType == .mirror || !$0.promptText.isEmpty }
    let mirror = recent.filter { $0.promptType == .mirror }
    let weeks = max(1.0, Double(days) / 7.0)

    return JournalSummary(
      totalEntries: recent.count,
      voiceEntries: voice.count,
      writtenEntries: recent.count - voice.count,
      mirrorEntries: mirror.count,
      entriesPerWeek: Double(recent.count) / weeks
    )
  }

  // MARK: - Streak Helpers

  private static func computeStreak(from checkIns: [FlameCheckIn], fromEnd: Bool) -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let dates = Set(checkIns.map { calendar.startOfDay(for: $0.date) })

    var streak = 0
    var checkDate = today

    // If no check-in today, start from yesterday
    if !dates.contains(today) {
      guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
        return 0
      }
      checkDate = yesterday
    }

    while dates.contains(checkDate) {
      streak += 1
      guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
        break
      }
      checkDate = prev
    }

    return streak
  }

  private static func computeLongestStreak(from checkIns: [FlameCheckIn]) -> Int {
    let calendar = Calendar.current
    let sorted = checkIns.map { calendar.startOfDay(for: $0.date) }.sorted()
    let unique = Array(Set(sorted)).sorted()

    guard !unique.isEmpty else { return 0 }

    var longest = 1
    var current = 1

    for idx in 1..<unique.count {
      let diff = calendar.dateComponents([.day], from: unique[idx - 1], to: unique[idx])
      if diff.day == 1 {
        current += 1
        longest = max(longest, current)
      } else {
        current = 1
      }
    }

    return longest
  }

  private static func bestDayOfWeek(from checkIns: [FlameCheckIn]) -> String? {
    guard !checkIns.isEmpty else { return nil }

    let calendar = Calendar.current
    var dayTotals: [Int: (total: Int, count: Int)] = [:]

    for checkIn in checkIns {
      let weekday = calendar.component(.weekday, from: checkIn.date)
      let existing = dayTotals[weekday, default: (0, 0)]
      dayTotals[weekday] = (existing.total + checkIn.score, existing.count + 1)
    }

    guard
      let best = dayTotals.max(by: {
        Double($0.value.total) / Double($0.value.count)
          < Double($1.value.total) / Double($1.value.count)
      })
    else { return nil }

    let formatter = DateFormatter()
    return formatter.weekdaySymbols[best.key - 1]
  }
}
