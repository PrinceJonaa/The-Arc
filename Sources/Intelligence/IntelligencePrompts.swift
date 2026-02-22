import Foundation

// MARK: - Prompt Builders

extension IntelligenceManager {
  // Token budget: ~4096 total
  // System instructions: ~300 tokens
  // Prompt data: ~800 tokens (pre-summarized)
  // Response budget: ~2500 tokens

  var patternInstructions: String {
    """
    You are a personal growth pattern analyst. \
    You analyze journal entries, flame scores, and moods to detect behavioral and emotional patterns. \
    Be specific and grounded in the data — never fabricate patterns that aren't supported. \
    Speak warmly but honestly. Keep observations concise.
    """
  }

  var driftInstructions: String {
    """
    You are a drift detector for a personal growth app. \
    The user has a Devotion Anchor — their core identity statement. \
    Compare their recent behavior (journals, flame scores) against this anchor. \
    Be honest but compassionate. If they're aligned, celebrate it. \
    If drifting, name it clearly without judgment. \
    Always provide one actionable suggestion.
    """
  }

  var recapInstructions: String {
    """
    You are a personal growth coach generating a weekly recap. \
    Synthesize patterns and drift analysis into a brief, powerful coaching message. \
    Reference the user's Devotion Anchor. Be encouraging but honest. \
    Keep each field to 1-2 sentences maximum.
    """
  }

  func buildPatternPrompt(
    journals: [String],
    flames: [(date: String, score: Int)],
    moods: [String]
  ) -> String {
    // Pre-summarize to fit context window
    let journalSummary = journals.prefix(5).enumerated().map { idx, body in
      "Entry \(idx + 1): \(String(body.prefix(200)))"
    }.joined(separator: "\n")

    let flameSummary = flames.prefix(14).map { "\($0.date): \($0.score)/10" }
      .joined(separator: ", ")

    let moodCounts = Dictionary(grouping: moods, by: { $0 })
      .mapValues(\.count)
      .map { "\($0.key): \($0.value)" }
      .joined(separator: ", ")

    return """
      Analyze the following 7-14 days of personal data and detect 2-3 patterns.

      FLAME SCORES (daily alignment 0-10):
      \(flameSummary.isEmpty ? "No check-ins yet" : flameSummary)

      MOOD DISTRIBUTION:
      \(moodCounts.isEmpty ? "No moods recorded" : moodCounts)

      RECENT JOURNAL ENTRIES:
      \(journalSummary.isEmpty ? "No entries yet" : journalSummary)

      Detect 2-3 patterns. Each pattern needs a title, category, observation, and signal strength.
      """
  }

  func buildDriftPrompt(
    anchor: String,
    journals: [String],
    flameAvg: Double,
    phase: String,
    tone: String
  ) -> String {
    let journalSummary = journals.prefix(4).enumerated().map { idx, body in
      "Entry \(idx + 1): \(String(body.prefix(200)))"
    }.joined(separator: "\n")

    return """
      Compare the user's recent behavior against their stated purpose.

      DEVOTION ANCHOR (their core identity statement):
      "\(anchor)"

      CURRENT PHASE: \(phase)
      PERSONALITY VOICE: \(tone)
      FLAME AVERAGE (last 14 days): \(String(format: "%.1f", flameAvg))/10

      RECENT JOURNALS:
      \(journalSummary.isEmpty ? "No entries" : journalSummary)

      Assess alignment vs drift. Be specific about what's aligned and what's pulling away.
      """
  }

  func buildRecapPrompt(
    anchor: String,
    patterns: [PatternResult],
    drift: DriftResult,
    flameAvg: Double,
    habitRate: Double
  ) -> String {
    let patternSummary = patterns.map { "\($0.categoryEmoji) \($0.title): \($0.observation)" }
      .joined(separator: "\n")

    return """
      Generate a weekly coaching recap.

      DEVOTION ANCHOR: "\(anchor)"
      FLAME AVERAGE: \(String(format: "%.1f", flameAvg))/10
      HABIT COMPLETION: \(Int(habitRate * 100))%

      DETECTED PATTERNS:
      \(patternSummary.isEmpty ? "No clear patterns yet" : patternSummary)

      DRIFT STATUS: \(drift.alignmentEmoji) \(drift.alignment)
      \(drift.headline)

      Create an encouraging weekly recap grounded in this data.
      """
  }
}

// MARK: - Mock Data (Simulator + Fallback)

extension IntelligenceManager {
  func mockPatterns() -> [PatternResult] {
    [
      PatternResult(
        title: "Morning clarity, evening doubt",
        category: "emotional",
        observation: """
          Your flame scores trend higher in morning check-ins. \
          Journal entries written after 8 PM carry more uncertainty. \
          This is normal — protect your mornings.
          """,
        strength: "strong"
      ),
      PatternResult(
        title: "Consistency builds confidence",
        category: "behavioral",
        observation: """
          Weeks where you complete 4+ habits correlate with flame \
          scores above 7. The routine is working.
          """,
        strength: "emerging"
      ),
    ]
  }

  func mockDrift() -> DriftResult {
    DriftResult(
      alignment: "aligned",
      headline: "Your actions match your words this week.",
      explanation: """
        Your journal entries and flame scores are consistent with \
        your stated devotion anchor. You're showing up for the thing \
        you said matters most.
        """,
      suggestion: "Keep your morning check-in streak going — it's anchoring your days."
    )
  }

  func mockRecap() -> RecapResult {
    RecapResult(
      headline: "Steady week — your flame averaged 7.2 and habits held strong.",
      win: "You journaled 5 out of 7 days — the most consistent week yet.",
      watchArea: "Evening flame dips suggest end-of-day fatigue. Consider a wind-down ritual.",
      closing: "You said you'd build this. You're building it. Keep going."
    )
  }
}
