import SwiftData
import SwiftUI

/// AI-powered insights dashboard: pattern detection + drift analysis + weekly recap.
struct AIInsightsView: View {
  @Environment(\.modelContext) private var modelContext
  @StateObject private var intelligence = IntelligenceManager()

  @Query(sort: \JournalEntry.date, order: .reverse)
  private var entries: [JournalEntry]

  @Query(sort: \FlameCheckIn.date, order: .reverse)
  private var checkIns: [FlameCheckIn]

  @Query(
    filter: #Predicate<Habit> { !$0.isArchived },
    sort: \Habit.createdAt
  )
  private var habits: [Habit]

  @Query private var profiles: [UserProfile]
  @Query(sort: \DevotionAnchor.createdAt, order: .reverse)
  private var anchors: [DevotionAnchor]

  @State private var patterns: [PatternResult] = []
  @State private var drift: DriftResult?
  @State private var recap: RecapResult?
  @State private var hasLoaded = false

  private var profile: UserProfile? { profiles.first }
  private var anchor: DevotionAnchor? { anchors.first }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        headerSection

        if intelligence.isProcessing {
          loadingSection
        } else if hasLoaded {
          if let drift {
            driftCard(drift)
          }

          if !patterns.isEmpty {
            patternsSection
          }

          if let recap {
            recapCard(recap)
          }
        }
      }
      .padding()
    }
    .navigationTitle("AI Insights")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          Task { await runAnalysis() }
        } label: {
          Label("Refresh", systemImage: "arrow.clockwise")
        }
        .disabled(intelligence.isProcessing)
      }
    }
    .task {
      if !hasLoaded {
        await runAnalysis()
      }
    }
  }

  // MARK: - Analysis Runner

  private func runAnalysis() async {
    let journalBodies = entries.prefix(5).map(\.body)
    let flameData = checkIns.prefix(14).map { checkIn in
      (
        date: checkIn.date.formatted(.dateTime.month(.abbreviated).day()),
        score: checkIn.score
      )
    }
    let moods = entries.prefix(20).map { $0.mood.label }

    // Pattern detection
    let detectedPatterns = await intelligence.detectPatterns(
      journalBodies: Array(journalBodies),
      flameScores: flameData,
      moods: moods
    )
    patterns = detectedPatterns

    // Drift detection
    if let anchorText = anchor?.statement {
      let flameAvg =
        InsightsEngine
        .flameSummary(from: checkIns, days: 14).average

      let detectedDrift = await intelligence.detectDrift(
        devotionAnchor: anchorText,
        recentJournals: Array(journalBodies),
        flameAverage: flameAvg,
        currentPhase: profile?.currentPhase.label ?? "Ignition",
        personalityTone: profile?.personalityTone.label ?? "Builder"
      )
      drift = detectedDrift

      // Weekly recap
      let habitRate =
        habits.isEmpty
        ? 0.0
        : habits.map { $0.completionRate(days: 7) }
          .reduce(0, +) / Double(habits.count)

      let generatedRecap = await intelligence.generateRecap(
        devotionAnchor: anchorText,
        patterns: detectedPatterns,
        drift: detectedDrift,
        flameAverage: flameAvg,
        habitCompletionRate: habitRate
      )
      recap = generatedRecap
    }

    hasLoaded = true
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 6) {
      HStack {
        Image(systemName: "brain.head.profile.fill")
          .font(.title2)
          .foregroundStyle(.purple)
        Text("Powered by Apple Intelligence")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text("Analysis of your last 14 days — all on-device, fully private.")
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)
    }
    .padding(.bottom, 4)
  }

  // MARK: - Loading

  private var loadingSection: some View {
    GlassCard {
      HStack(spacing: 12) {
        ProgressView()
        VStack(alignment: .leading, spacing: 2) {
          Text("Analyzing your patterns…")
            .font(.subheadline.weight(.medium))
          Text("On-device. Private. No data leaves your phone.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  // MARK: - Drift

  private func driftCard(_ drift: DriftResult) -> some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text(drift.alignmentEmoji)
            .font(.title2)
          Text("Drift Analysis")
            .font(.headline.weight(.semibold))
          Spacer()
          Text(drift.alignment.capitalized)
            .font(.caption.weight(.semibold))
            .foregroundStyle(driftColor(drift.alignment))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
              Capsule(style: .continuous)
                .fill(driftColor(drift.alignment).opacity(0.12))
            }
        }

        Text(drift.headline)
          .font(.subheadline.weight(.medium))
          .foregroundStyle(.primary)

        Text(drift.explanation)
          .font(.caption)
          .foregroundStyle(.secondary)

        Divider()

        HStack(spacing: 6) {
          Image(systemName: "lightbulb.fill")
            .foregroundStyle(.yellow)
            .font(.caption)
          Text(drift.suggestion)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  // MARK: - Patterns

  private var patternsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Detected Patterns")
        .font(.headline.weight(.semibold))
        .padding(.horizontal, 4)

      ForEach(patterns) { pattern in
        patternCard(pattern)
      }
    }
  }

  private func patternCard(_ pattern: PatternResult) -> some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(pattern.categoryEmoji)
            .font(.title3)
          Text(pattern.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
          Spacer()
          Text(pattern.strength)
            .font(.caption2.weight(.medium))
            .foregroundStyle(strengthColor(pattern.strength))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background {
              Capsule(style: .continuous)
                .fill(strengthColor(pattern.strength).opacity(0.12))
            }
        }

        Text(pattern.observation)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }

  // MARK: - Recap

  private func recapCard(_ recap: RecapResult) -> some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text("📋")
            .font(.title2)
          Text("Weekly Recap")
            .font(.headline.weight(.semibold))
        }

        Text(recap.headline)
          .font(.subheadline.weight(.medium))
          .foregroundStyle(.primary)

        HStack(alignment: .top, spacing: 6) {
          Image(systemName: "star.fill")
            .foregroundStyle(.green)
            .font(.caption)
          Text(recap.win)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        HStack(alignment: .top, spacing: 6) {
          Image(systemName: "eye.fill")
            .foregroundStyle(.orange)
            .font(.caption)
          Text(recap.watchArea)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Divider()

        Text(recap.closing)
          .font(.caption.italic())
          .foregroundStyle(.secondary)
      }
    }
  }

  // MARK: - Helpers

  private func driftColor(_ alignment: String) -> Color {
    switch alignment {
    case "aligned": .green
    case "drifting": .orange
    case "misaligned": .red
    default: .blue
    }
  }

  private func strengthColor(_ strength: String) -> Color {
    switch strength {
    case "strong": .green
    case "emerging": .orange
    case "fading": .gray
    default: .blue
    }
  }
}

#Preview {
  NavigationStack {
    AIInsightsView()
  }
  .modelContainer(
    for: [
      JournalEntry.self, FlameCheckIn.self,
      Habit.self, UserProfile.self, DevotionAnchor.self,
    ],
    inMemory: true
  )
}
