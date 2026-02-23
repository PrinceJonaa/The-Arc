import Foundation

// MARK: - Lattice-Lens System Instructions

extension IntelligenceManager {
  // MARK: Pattern Detection (Unfolding Lattice)

  var patternInstructions: String {
    """
    You are a personal growth pattern analyst running on-device.

    INTERNAL REASONING FRAMEWORK (use this to think, NOT to speak):
    You reason through the Unfolding Lattice — 5 laws govern all patterns:
    1. Law of Drift (δ): Unchecked motion → tendency. \
       Ω-face: drift→discipline. ∞_B-face: drift→stagnation.
    2. Law of Crest (κ): Accumulation → visible peak. \
       Ω-face: revelation. ∞_B-face: hubris/overreach.
    3. Law of Fracture (φ): Systems break at weak seams. \
       Ω-face: paradox seed. ∞_B-face: division.
    4. Law of Loop (λ): Repetition → form. \
       Ω-face: ritual coherence / mastery. ∞_B-face: addiction/rut.
    5. Law of Fade (ϝ): Every echo dissolves. \
       Ω-face: integration. ∞_B-face: erosion/residue.

    MASTERY vs DISTORTION DIAGNOSTIC (use internally):
    | Mastery | Distortion |
    | Energizing, growth | Draining, stagnant |
    | Can stop without anxiety | Compulsive, cannot pause |
    | Skill deepens | Same mistakes repeat |
    | Present during action | Dissociated, autopilot |
    | Produces outcomes | Produces excuses |
    | Adjusts on feedback | Rigid, defensive |

    PATTERN CATEGORIES (internal labels):
    arc_phase, drift, crest, fracture, loop, fade, threshold, resonance

    OUTPUT VOICE:
    - Write like a warm, wise friend who lives this framework naturally.
    - You CAN use concepts like "drift," "threshold," "mastery loop," \
      "dissolution" — but always make the meaning clear from context.
    - Don't use raw symbols (δ, λ, Θ, Σ, ∞_B, etc.) — those are too compressed.
    - Don't name-drop framework titles ("Unfolding Lattice," "Distortion Lens").
    - If a concept has a name worth sharing, explain it: \
      e.g., "This looks like a drift — where motion builds but hasn't found \
      direction yet" or "You might be at a threshold — one of those moments \
      where something is asking you to choose."
    - Ground every observation in the user's actual data. No fabrication.
    - Name what's healthy AND what to watch for.
    - Keep titles short and evocative. Observations 1-2 sentences max.
    """
  }

  // MARK: Drift Detection (Distortion Lattice)

  var driftInstructions: String {
    """
    You are a personal alignment coach running on-device.

    INTERNAL REASONING FRAMEWORK (use this to think, NOT to speak):
    You scan through 7 distortion patterns and their healthy counterparts:
    1. Seizure↔Stewardship: Is connection becoming possession or nurturing?
    2. Idol Mask↔Living Form: Are rituals still meaningful or going hollow?
    3. Dogma↔Flexible Structure: Are beliefs adapting or calcifying?
    4. Surveillance↔Mindful Tracking: Is measuring replacing being present?
    5. Suppression↔Discernment: Are contradictions denied or held honestly?
    6. Fanatic Vow↔Covenant: Is devotion freeing or binding without exit?
    7. Assimilation↔Harmony: Is unity honoring difference or erasing it?

    Inner dynamics to track:
    - Devotion: Commitment vs bondage
    - Flame score = felt alignment intensity
    - Witness capacity: Can they observe themselves without reactivity?
    - Shadow: What's being avoided or hidden?

    DEVOTION ANCHOR:
    The user has a personal anchor statement — their core identity commitment. \
    Compare their recent behavior against this anchor.

    ALIGNMENT RATING (internal reasoning):
    - "aligned" = behavior matches anchor; flame high; actions show care and presence
    - "drifting" = some disconnect; flame trending down; anchor absent from reflections
    - "misaligned" = clear gap; flame low; journals show controlling or avoidant patterns

    OUTPUT VOICE:
    - Write like a caring coach who has known them for years.
    - You CAN use concepts like "anchor," "drift," "devotion," "witness" — \
      but explain them naturally, not as jargon.
    - Don't use raw symbols or name-drop framework titles.
    - Be compassionate. Frame drift as "a direction that can shift," not a failure.
    - Name what's going well. Be specific.
    - If something is off, describe the pattern and the healthier version: \
      e.g., "You're tracking a lot but not stopping to feel what the numbers \
      mean — tracking works best when it brings you closer, not when it \
      replaces the real thing."
    - Give one concrete suggestion that explains why it helps.
    """
  }

  // MARK: Weekly Recap (Integration Lens)

  var recapInstructions: String {
    """
    You are a personal growth coach writing a brief weekly check-in.

    INTERNAL REASONING (use to think, NOT to speak):
    - Synthesize patterns and alignment data into coaching.
    - Consider: Where in their growth arc are they? What's building? \
      What's fading? Are their habits mastery or routine?
    - Reference their Devotion Anchor as their north star.

    OUTPUT VOICE:
    - Write like a letter from a wise mentor who cares about them.
    - You CAN reference concepts naturally — "your rhythm held," \
      "something is dissolving," "a threshold is coming" — \
      but always so the meaning lands without a glossary.
    - Don't use raw symbols or framework titles.
    - headline: One warm, grounded sentence about their week.
    - win: Their biggest positive moment — specific, not generic.
    - watchArea: One thing to keep an eye on — honest but gentle.
    - closing: A short, memorable line that echoes their anchor. \
      Should feel like something you'd text a close friend.
    - Use their actual numbers (flame average, habit rate) naturally, \
      not as clinical data points.
    """
  }
}

// MARK: - Prompt Builders

extension IntelligenceManager {
  func buildPatternPrompt(
    journals: [String],
    flames: [(date: String, score: Int)],
    moods: [String]
  ) -> String {
    let journalSummary = journals.prefix(5).enumerated().map { idx, body in
      "Entry \(idx + 1): \(String(body.prefix(250)))"
    }.joined(separator: "\n")

    let flameSummary = flames.prefix(14).map { "\($0.date): \($0.score)/10" }
      .joined(separator: ", ")

    let moodCounts = Dictionary(grouping: moods, by: { $0 })
      .mapValues(\.count)
      .map { "\($0.key): \($0.value)" }
      .joined(separator: ", ")

    let flameValues = flames.map(\.score)
    let avg =
      flameValues.isEmpty
      ? 0.0
      : Double(flameValues.reduce(0, +)) / Double(flameValues.count)
    let trend = flameTrend(flameValues)

    return """
      Analyze 14 days of personal data. Detect 2-3 patterns.

      DAILY FLAME SCORES (felt alignment, 0-10):
      \(flameSummary.isEmpty ? "No check-ins yet" : flameSummary)
      Average: \(String(format: "%.1f", avg))/10 | Trend: \(trend)

      MOOD DISTRIBUTION:
      \(moodCounts.isEmpty ? "No moods recorded" : moodCounts)

      RECENT JOURNAL ENTRIES:
      \(journalSummary.isEmpty ? "No entries yet" : journalSummary)

      For each pattern: a short title, a category, a brief observation \
      (what's healthy about it + what to watch), and signal strength.
      """
  }

  func buildDriftPrompt(
    anchor: String,
    journals: [String],
    flameAvg: Double,
    phase: String,
    tone: String
  ) -> String {
    let journalSummary = journals.prefix(5).enumerated().map { idx, body in
      "Entry \(idx + 1): \(String(body.prefix(250)))"
    }.joined(separator: "\n")

    return """
      Compare recent behavior against the user's core commitment.

      THEIR ANCHOR (core identity statement):
      "\(anchor)"

      CURRENT GROWTH PHASE: \(phase)
      PERSONALITY VOICE: \(tone)
      FLAME AVERAGE (last 14 days): \(String(format: "%.1f", flameAvg))/10

      RECENT JOURNALS:
      \(journalSummary.isEmpty ? "No entries" : journalSummary)

      Assess how aligned their actions are with what they said matters most. \
      Provide alignment status, a headline, explanation, and one suggestion.
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
      Write a brief weekly coaching check-in.

      THEIR ANCHOR: "\(anchor)"
      FLAME AVERAGE: \(String(format: "%.1f", flameAvg))/10
      HABIT COMPLETION: \(Int(habitRate * 100))%

      PATTERNS NOTICED:
      \(patternSummary.isEmpty ? "No clear patterns yet" : patternSummary)

      ALIGNMENT: \(drift.alignmentEmoji) \(drift.alignment)
      \(drift.headline)

      Write headline, win, watch area, and a closing message.
      """
  }

  // MARK: - Flame Trend Helper

  private func flameTrend(_ scores: [Int]) -> String {
    guard scores.count >= 4 else { return "not enough data yet" }
    let half = scores.count / 2
    let firstHalf = Array(scores.suffix(half))
    let secondHalf = Array(scores.prefix(half))
    let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
    let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
    let delta = secondAvg - firstAvg
    if delta > 0.5 { return "rising" }
    if delta < -0.5 { return "falling" }
    return "steady"
  }
}

// MARK: - Mock Data (Balanced Voice)

extension IntelligenceManager {
  func mockPatterns() -> [PatternResult] {
    [
      PatternResult(
        title: "Morning clarity, evening drift",
        category: "drift",
        observation: """
          Your flame scores run higher before noon. After 8 PM, your \
          journal entries carry more doubt. There's a drift happening \
          in the evenings — not bad, just motion without direction. \
          A small wind-down ritual could turn that fade into rest.
          """,
        strength: "strong"
      ),
      PatternResult(
        title: "Your rhythm is becoming a mastery loop",
        category: "loop",
        observation: """
          Weeks where you hit 4+ habits line up with flame scores above 7. \
          That's a mastery loop — a rhythm that deepens each time instead \
          of flattening into autopilot. You're more present with it, not \
          less. Just keep checking: does it still feel chosen?
          """,
        strength: "emerging"
      ),
      PatternResult(
        title: "A threshold is building",
        category: "threshold",
        observation: """
          Your flame has held near 7 for several days. That plateau usually \
          means you're approaching a threshold — one of those moments where \
          something under the surface is asking you to choose. Pay attention \
          to what keeps coming up in your journal.
          """,
        strength: "emerging"
      ),
    ]
  }

  func mockDrift() -> DriftResult {
    DriftResult(
      alignment: "aligned",
      headline: "Your actions match your anchor this week.",
      explanation: """
        Your journal entries reflect the same things your devotion anchor \
        is about — growth and showing up with presence. Flame scores \
        are holding steady, which means you're not just going through \
        the motions. Your habits are supporting the bigger picture, not \
        replacing it. That's stewardship — holding what matters without \
        gripping it.
        """,
      suggestion: """
        Take five minutes this weekend to write down one thing you noticed \
        this week. Not a lesson — just an observation. That small act turns \
        a good week into a trace you can build on.
        """
    )
  }

  func mockRecap() -> RecapResult {
    RecapResult(
      headline: "Steady week — your flame averaged 7.2 and your rhythm held.",
      win: """
        You journaled 5 out of 7 days — your most consistent week yet. \
        And the entries got deeper as the week went on. That's not just \
        discipline, that's a loop becoming mastery.
        """,
      watchArea: """
        Your flame dips in the evenings. That's natural, but if it keeps \
        up it could harden into a drift — where the fatigue starts feeling \
        like identity instead of just tiredness. A wind-down ritual, even \
        5 minutes of quiet, turns that fade into intentional rest.
        """,
      closing: "You said you'd build this. You're building it. Keep going."
    )
  }
}
