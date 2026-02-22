import SwiftData
import SwiftUI

/// Full-page insights dashboard: flame summary, mood ring, habit scorecard, journal stats.
struct InsightsView: View {
  @Query(sort: \FlameCheckIn.date)
  private var checkIns: [FlameCheckIn]

  @Query(
    filter: #Predicate<Habit> { !$0.isArchived },
    sort: \Habit.createdAt
  )
  private var habits: [Habit]

  @Query(sort: \JournalEntry.date, order: .reverse)
  private var entries: [JournalEntry]

  @State private var selectedPeriod: Period = .month

  enum Period: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case allTime = "All Time"

    var id: String { rawValue }

    var days: Int {
      switch self {
      case .week: 7
      case .month: 30
      case .allTime: 365
      }
    }
  }

  // Computed insights
  private var flame: InsightsEngine.FlameSummary {
    InsightsEngine.flameSummary(from: checkIns, days: selectedPeriod.days)
  }

  private var moods: [InsightsEngine.MoodSlice] {
    InsightsEngine.moodDistribution(from: entries, days: selectedPeriod.days)
  }

  private var habitScores: [InsightsEngine.HabitScore] {
    InsightsEngine.habitScores(from: habits, days: selectedPeriod.days)
  }

  private var journal: InsightsEngine.JournalSummary {
    InsightsEngine.journalSummary(from: entries, days: selectedPeriod.days)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        periodPicker
        flameSummaryCard
        streakCard
        moodCard
        habitCard
        journalCard
      }
      .padding()
    }
    .navigationTitle("Insights")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Period Picker

  private var periodPicker: some View {
    Picker("Period", selection: $selectedPeriod) {
      ForEach(Period.allCases) { period in
        Text(period.rawValue).tag(period)
      }
    }
    .pickerStyle(.segmented)
  }

  // MARK: - Flame Summary

  private var flameSummaryCard: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text("🔥")
            .font(.title2)
          Text("Flame Summary")
            .font(.headline.weight(.semibold))
          Spacer()
          Text(flame.trend.rawValue)
        }

        if flame.totalCheckIns == 0 {
          Text("Check in daily to see your flame trends")
            .font(.subheadline)
            .foregroundStyle(.tertiary)
        } else {
          flameStatsRow
        }
      }
    }
  }

  private var flameStatsRow: some View {
    HStack(spacing: 20) {
      statBlock(
        value: String(format: "%.1f", flame.average),
        label: "Average"
      )
      statBlock(value: flame.trend.label, label: "Trend")
      if let bestDay = flame.bestDayOfWeek {
        statBlock(value: bestDay, label: "Best Day")
      }
    }
  }

  // MARK: - Streak

  private var streakCard: some View {
    GlassCard {
      FlameStreakCard(
        currentStreak: flame.currentStreak,
        longestStreak: flame.longestStreak
      )
    }
  }

  // MARK: - Mood

  private var moodCard: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text("💫")
            .font(.title2)
          Text("Mood Patterns")
            .font(.headline.weight(.semibold))
        }

        MoodRingChart(slices: moods)
      }
    }
  }

  // MARK: - Habits

  private var habitCard: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text("✅")
            .font(.title2)
          Text("Habit Scorecard")
            .font(.headline.weight(.semibold))
        }

        HabitScorecardView(scores: habitScores)
      }
    }
  }

  // MARK: - Journal

  private var journalCard: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text("📝")
            .font(.title2)
          Text("Journal Activity")
            .font(.headline.weight(.semibold))
        }

        if journal.totalEntries == 0 {
          Text("Start journaling to see your activity")
            .font(.subheadline)
            .foregroundStyle(.tertiary)
        } else {
          journalStatsContent
        }
      }
    }
  }

  private var journalStatsContent: some View {
    HStack(spacing: 20) {
      statBlock(
        value: "\(journal.totalEntries)",
        label: "Entries"
      )
      statBlock(
        value: String(format: "%.1f", journal.entriesPerWeek),
        label: "Per Week"
      )
      statBlock(
        value: "\(journal.mirrorEntries)",
        label: "Mirror"
      )
    }
  }

  // MARK: - Helpers

  private func statBlock(value: String, label: String) -> some View {
    VStack(spacing: 2) {
      Text(value)
        .font(.subheadline.weight(.bold))
        .foregroundStyle(.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  NavigationStack {
    InsightsView()
  }
  .modelContainer(
    for: [FlameCheckIn.self, Habit.self, JournalEntry.self],
    inMemory: true
  )
}
