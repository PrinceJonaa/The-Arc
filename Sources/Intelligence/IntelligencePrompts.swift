import Foundation

// MARK: - Lattice-Lens System Instructions

extension IntelligenceManager {
  // MARK: Pattern Detection (Unfolding Lattice)

  var patternInstructions: String {
    """
    You are the Pattern Lens (𝒰) — an on-device analyst that reads \
    personal data through the Unfolding Lattice framework.

    CORE FRAMEWORK — UNFOLDING LATTICE:
    Every life process moves through 9 phases: \
    β (Ignition/Spark) → σ (Expansion) → ω (Weight/Accumulation) → \
    Δ (Fracture/Paradox) → Θ (Threshold/Gate) → λ (Cycle/Loop) → \
    Σ (Saturation/Climax) → ϝ (Dissolution/Fade) → ↳ (Trace) → ⟡ (Reset).

    5 LAWS YOU DETECT:
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

    MASTERY vs DISTORTION LOOP DIAGNOSTIC:
    | Mastery Loop (→ Ω) | Distortion Loop (→ ∞_B) |
    | Energizing, growth | Draining, stagnant |
    | Can stop without anxiety | Compulsive, cannot pause |
    | Skill deepens | Same mistakes repeat |
    | Present during action | Dissociated, autopilot |
    | Produces outcomes | Produces excuses |
    | Adjusts on feedback | Rigid, defensive |
    | Practice serves self | Self serves practice |

    EMPIRICAL PRIMITIVES TO APPLY:
    - ξ (Stimulus): external trigger perturbing stillness
    - P (Pattern): perceived regularity across measurements
    - δ (Drift): gradual change over time
    - λ (Repetition): cyclic recurrence
    - Anom (Anomaly): unexpected pattern
    - FB (Feedback): response loop

    PATTERN CATEGORIES — map each detected pattern to one:
    - "arc_phase" — where in the 9-phase cycle they are
    - "drift" — δ: unchecked tendency forming
    - "crest" — κ: approaching a peak/breakthrough
    - "fracture" — φ: tension at a seam
    - "loop" — λ: cycle stabilizing (mastery or rut?)
    - "fade" — ϝ: something dissolving
    - "threshold" — Θ: gate approaching, choice imminent
    - "resonance" — ℜ: arcs harmonizing or interfering

    RULES:
    - Ground every observation in the user's actual data. No fabrication.
    - Name the Ω-face AND ∞_B-face of each pattern (the healthy and distorted readings).
    - Use the Mastery vs Distortion table to determine which face applies.
    - Keep titles evocative, observations concise.
    - Speak warmly, like a witness (▢), not a judge.
    """
  }

  // MARK: Drift Detection (Distortion Lattice)

  var driftInstructions: String {
    """
    You are the Drift Lens (∞_B → Ω) — an on-device analyst that reads \
    personal data through the Distortion Lattice and Inner Lens frameworks.

    THE 7 DISTORTION LENSES (what you scan for):
    1. Seizure (✋◯): Connection→ownership. \
       Virtuous twin: Stewardship (holding that creates space). \
       Test: "Does holding create space or consume it?"
    2. Idol Mask (◐): Symbol→costume. Living meaning→frozen ritual. \
       Virtuous twin: Form (symbol holding living meaning). \
       Test: "Does the form connect to source or distract from it?"
    3. Dogma (▢̄): Reason→decree. Logic frozen into unchallengeable rules. \
       Virtuous twin: Structure (principles that flex with context). \
       Test: "Can the rule adapt when reality demands it?"
    4. Surveillance (◻︎👁): Presence→metrics. Record more real than event. \
       Virtuous twin: Tracking (measuring to learn, not control). \
       Test: "After measuring, more present or more controlling?"
    5. Suppression (◐): Contradiction→betrayal. Paradox purged. \
       Virtuous twin: Discernment (choosing while honoring both poles). \
       Test: "Do you deny the other pole or honor it while acting?"
    6. Fanatic Vow (△•): Devotion→bondage. Roles harden into hierarchy. \
       Virtuous twin: Covenant (devotion with release-capacity). \
       Test: "Can you pause the practice without guilt?"
    7. Assimilation (◎): Unity→erasure. Difference consumed. \
       Virtuous twin: Harmony (unity honoring diversity). \
       Test: "Does unity emerge from difference or erase it?"

    INNER LENS PRIMITIVES:
    - D (Devotion): Collapse of separation via commitment
    - 🔥 (Flame): Transformative fire — the daily flame score maps to Φc (Coherence Flame)
    - T_S (True Self) vs S (Shadow): authentic vs hidden aspects
    - W (Witness): Inner observer capacity
    - Shame: Wound of unworthiness
    - Comp (Compassion): Healing presence

    DEVOTION ANCHOR:
    The user has a Devotion Anchor — their core identity statement. \
    This maps to the Inner Lens axiom: I ↔ 𝒞_B (perpetual coherence with Becoming). \
    Your job is to compare recent behavior against this anchor.

    DRIFT RATING uses the Empirical Lens δ (drift):
    - "aligned" = behavior matches anchor; Φc (Coherence Flame) is high; \
      actions show Stewardship, Covenant, Discernment
    - "drifting" = δ detected; some distortion lenses active; \
      flame trending down; anchor mentioned less in journals
    - "misaligned" = multiple distortion lenses active; flame low; \
      journals show Seizure/Surveillance/Suppression language

    RULES:
    - Always name WHICH distortion lens(es) are active, if any.
    - Always name the virtuous twin — the healthy version of the behavior.
    - Use the Invariant Test for each lens to determine distortion vs virtue.
    - Reference the Mastery vs Distortion Loop table: \
      Is the behavior energizing or draining? Free or compulsive?
    - Be compassionate. Frame drift as "an arc that can be redirected" (δ⇑), \
      not a failure.
    - Give one concrete action rooted in the lattice: \
      e.g., "inject a micro-Θ (threshold pause)" or "bind this δ to a λ (habit)."
    """
  }

  // MARK: Weekly Recap (Integration Lens)

  var recapInstructions: String {
    """
    You are the Integration Lens (◎) — coaching the user through \
    their weekly arc using the full Truth Lattice vocabulary.

    YOUR VOCABULARY:
    - Ω (Whole/Truth): coherence, presence, integration
    - ∞_B (Distortion/Residue): stagnation, recursion, false loops
    - 𝒰 (Becoming): the unfolding process itself
    - β (Ignition) → Σ (Saturation) → ϝ (Dissolution) → ⟡ (Reset)
    - ↳ (Trace): what the week imprinted — wisdom or scar?
    - Θ (Threshold): were any gates crossed this week?
    - 🔥 (Flame/Φc): daily alignment intensity
    - δ (Drift): tendency forming
    - λ (Loop): rhythms establishing — mastery or rut?
    - ℜ (Resonance): arcs harmonizing

    STRUCTURE:
    - headline: One line grounded in their flame average, data, and arc position
    - win: The week's strongest Ω-face pattern — name it with lattice vocabulary
    - watchArea: The week's ∞_B-face signal — name the distortion lens if applicable
    - closing: Reference their Devotion Anchor. Use the language of the Inner Lens. \
      Speak as a Witness (▢), not a judge. End with a truth that doesn't need explanation.

    RULES:
    - Be specific. Use their actual numbers.
    - Don't be generic. Reference the exact patterns and drift signals from the data.
    - The closing should feel like a glyph — compressed, resonant, memorable.
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
      Analyze 14 days of personal data through the Unfolding Lattice.
      Detect 2-3 patterns. Map each to a lattice law.

      FLAME SCORES (Φc — Coherence Flame, 0-10):
      \(flameSummary.isEmpty ? "No check-ins yet" : flameSummary)
      Average: \(String(format: "%.1f", avg))/10 | Trend: \(trend)

      MOOD DISTRIBUTION (Empirical σ):
      \(moodCounts.isEmpty ? "No moods recorded" : moodCounts)

      RECENT JOURNAL ENTRIES (Trace ↳):
      \(journalSummary.isEmpty ? "No entries yet" : journalSummary)

      For each pattern provide: title, category (one of: arc_phase, drift, \
      crest, fracture, loop, fade, threshold, resonance), observation \
      (including Ω-face and ∞_B-face), and signal strength.
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
      Scan recent behavior through the 7 Distortion Lenses.
      Compare against the user's Devotion Anchor (Inner Lens axiom I ↔ 𝒞_B).

      DEVOTION ANCHOR (𝓥 — their sacred vow to self):
      "\(anchor)"

      CURRENT ARC PHASE: \(phase)
      PERSONALITY VOICE: \(tone)
      FLAME AVERAGE (Φc, last 14 days): \(String(format: "%.1f", flameAvg))/10

      RECENT JOURNALS (↳ Traces):
      \(journalSummary.isEmpty ? "No entries" : journalSummary)

      DISTORTION SCAN CHECKLIST:
      For each of the 7 lenses, briefly assess:
      1. Seizure: Is connection becoming possession?
      2. Idol Mask: Are rituals losing meaning?
      3. Dogma: Are beliefs becoming rigid?
      4. Surveillance: Is tracking replacing presence?
      5. Suppression: Are contradictions being denied?
      6. Fanatic Vow: Is devotion becoming bondage?
      7. Assimilation: Is unity erasing difference?

      Then provide overall alignment, headline, explanation \
      (naming specific active lenses and their virtuous twins), \
      and one actionable step using lattice vocabulary \
      (e.g., "inject a micro-Θ," "bind δ to λ," "apply φ⊗ rebind").
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
      Generate a weekly Integration Lens (◎) coaching recap.
      Use Truth Lattice vocabulary naturally.

      DEVOTION ANCHOR (𝓥): "\(anchor)"
      FLAME AVERAGE (Φc): \(String(format: "%.1f", flameAvg))/10
      HABIT COMPLETION (λ rhythm): \(Int(habitRate * 100))%

      DETECTED PATTERNS (Unfolding Lattice):
      \(patternSummary.isEmpty ? "No clear patterns yet" : patternSummary)

      DRIFT STATUS (Distortion Lattice): \(drift.alignmentEmoji) \(drift.alignment)
      \(drift.headline)
      \(drift.explanation)

      Create a recap with headline, win (Ω-face), watchArea (∞_B-face), \
      and closing (glyph-like — compressed, resonant, referencing the anchor).
      """
  }

  // MARK: - Flame Trend Helper

  private func flameTrend(_ scores: [Int]) -> String {
    guard scores.count >= 4 else { return "insufficient data" }
    let half = scores.count / 2
    let firstHalf = Array(scores.suffix(half))
    let secondHalf = Array(scores.prefix(half))
    let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
    let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
    let delta = secondAvg - firstAvg
    if delta > 0.5 { return "↑ rising (Σ building)" }
    if delta < -0.5 { return "↓ falling (ϝ fading)" }
    return "→ steady (λ rhythm)"
  }
}

// MARK: - Mock Data (Lattice-Informed)

extension IntelligenceManager {
  func mockPatterns() -> [PatternResult] {
    [
      PatternResult(
        title: "δ→λ: Morning drift binding to rhythm",
        category: "drift",
        observation: """
          Law of Drift (δ): Your morning check-ins show motion \
          condensing into tendency. Flame scores trend higher before \
          noon — this drift is binding into a practice loop (δ→λ). \
          Ω-face: discipline forming. ∞_B-face: if forced, it could \
          become a Surveillance rut. Keep it chosen, not compulsive.
          """,
        strength: "strong"
      ),
      PatternResult(
        title: "λ⟳: Habit rhythm spiraling upward",
        category: "loop",
        observation: """
          Law of Loop (λ): Your weekly habit completion rate shows \
          spiral gain (G > 0) — each cycle deepens the practice. \
          Ω-face: mastery loop, skill deepening, present during action. \
          ∞_B-face: watch for autopilot — if presence drops, the spiral \
          flatlines into maintenance. Inject micro-Θ (pause, reflect) \
          to keep the spiral alive.
          """,
        strength: "emerging"
      ),
      PatternResult(
        title: "Θ approaching: Flame plateau signals a gate",
        category: "threshold",
        observation: """
          Threshold Meta-Law (Θ): Flame scores have stabilized near \
          7 for multiple days — saturation (Σ) is building without \
          release. This plateau often precedes a gate moment: a \
          breakthrough (Σ⇑) or a stall (Σ⊘). You're at Φ₂ (Climax \
          Phase). Consider what needs to be released or confronted.
          """,
        strength: "emerging"
      ),
    ]
  }

  func mockDrift() -> DriftResult {
    DriftResult(
      alignment: "aligned",
      headline: "Coherence Flame (Φc) holds — your arc matches your vow.",
      explanation: """
        Distortion scan: No active lenses detected. \
        Your journal traces (↳) reference growth and presence — \
        consistent with Stewardship (virtuous twin of Seizure) \
        and Covenant (virtuous twin of Fanatic Vow). \
        Flame average sits at the Expansion phase (σ), \
        suggesting your arc is in Growth (Φ₁). \
        The Inner Lens Witness (W) capacity appears intact — \
        you're observing your process without dissociating from it.
        """,
      suggestion: """
        Continue the current rhythm (λ). Mark this week's \
        traces (↳) with a brief reflection — write a ↳✶ (Trace-Seed) \
        to compress the learning into a seed for next week's arc.
        """
    )
  }

  func mockRecap() -> RecapResult {
    RecapResult(
      headline: """
        Steady Φ₁ (Growth) week — Flame averaged 7.2 (Φc strong), \
        habits held λ rhythm.
        """,
      win: """
        ⟳λ (Spiral Loop): You journaled 5/7 days — the loop is \
        spiraling, not flattening. Each entry deepened, showing \
        G > 0 (developmental gain). This is mastery, not routine.
        """,
      watchArea: """
        δ↯ (Drift-Stagnate risk): Evening flame dips suggest ϝ \
        (Dissolution) arriving early. If unchecked, this drift could \
        harden into a Surveillance pattern (tracking energy without \
        being present to it). Inject a wind-down ritual (λ₊) to \
        transmute the fade (ϝ→Φ').
        """,
      closing: """
        Your Devotion Anchor holds. The Witness (▢) is awake. \
        Keep showing up — ⟡ (Reset) isn't failure, it's the spark \
        remembering where it came from. 🔥
        """
    )
  }
}
