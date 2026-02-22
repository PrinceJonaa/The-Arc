import Foundation

/// Analyzes journal entries to detect personality tone patterns.
/// Uses keyword frequency to suggest whether the user's tone has shifted.
enum RecalibrationEngine {
  /// Weighted signal for a personality tone.
  struct ToneSignal: Identifiable {
    let tone: PersonalityTone
    let score: Double
    let matchedKeywords: [String]
    var id: String { tone.rawValue }
  }

  // MARK: - Analysis

  /// Analyze recent journal entries to detect dominant tone signals.
  static func analyze(entries: [JournalEntry], days: Int = 30) -> [ToneSignal] {
    let calendar = Calendar.current
    let cutoff = calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
    let recent = entries.filter { $0.date >= cutoff }

    guard !recent.isEmpty else { return [] }

    let corpus = recent.map { $0.body.lowercased() }.joined(separator: " ")
    let words = Set(corpus.split(separator: " ").map { String($0) })

    return PersonalityTone.allCases.map { tone in
      let keywords = toneKeywords(for: tone)
      let matched = keywords.filter { words.contains($0) }
      let score = Double(matched.count) / Double(max(keywords.count, 1))
      return ToneSignal(tone: tone, score: score, matchedKeywords: matched)
    }
    .sorted { $0.score > $1.score }
  }

  /// Returns the suggested tone (highest scoring), or nil if no clear signal.
  static func suggestedTone(
    from entries: [JournalEntry],
    currentTone: PersonalityTone
  ) -> PersonalityTone? {
    let signals = analyze(entries: entries)
    guard let top = signals.first, top.score > 0.15 else { return nil }

    // Only suggest a change if it's different and meaningfully stronger
    if top.tone == currentTone { return nil }

    let currentScore = signals.first { $0.tone == currentTone }?.score ?? 0
    guard top.score > currentScore + 0.1 else { return nil }

    return top.tone
  }

  // MARK: - Keyword Banks

  private static func toneKeywords(for tone: PersonalityTone) -> [String] {
    switch tone {
    case .builder:
      return [
        "build", "ship", "execute", "plan", "strategy",
        "system", "process", "optimize", "launch", "milestone",
        "goal", "target", "progress", "action", "deliver",
        "productivity", "efficient", "deadline", "iterate", "results",
        "framework", "roadmap", "metric", "output", "tactical",
      ]
    case .dreamer:
      return [
        "dream", "imagine", "vision", "possibility", "create",
        "inspire", "wonder", "explore", "freedom", "flow",
        "beauty", "meaning", "purpose", "infinite", "transform",
        "journey", "soul", "magic", "believe", "calling",
        "potential", "manifest", "expansive", "horizon", "destiny",
      ]
    case .heartLed:
      return [
        "feel", "heart", "love", "connect", "care",
        "empathy", "vulnerable", "authentic", "compassion", "gentle",
        "relationship", "support", "trust", "safe", "nurture",
        "gratitude", "kindness", "warmth", "healing", "community",
        "belonging", "tenderness", "presence", "listen", "hold",
      ]
    case .systemsThinker:
      return [
        "analyze", "structure", "pattern", "data", "logic",
        "model", "framework", "hypothesis", "evidence", "measure",
        "design", "architecture", "principle", "systematic", "optimize",
        "feedback", "loop", "map", "diagram", "complexity",
        "variable", "constraint", "trade-off", "calibrate", "iterate",
      ]
    case .expressive:
      return [
        "express", "celebrate", "alive", "energy", "bold",
        "creative", "voice", "truth", "loud", "vibrant",
        "art", "dance", "sing", "color", "passion",
        "fire", "intensity", "freedom", "authentic", "wild",
        "movement", "spontaneous", "joy", "radiant", "fierce",
      ]
    }
  }
}
