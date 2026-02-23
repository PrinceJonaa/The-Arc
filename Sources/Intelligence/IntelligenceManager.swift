import Foundation

#if canImport(FoundationModels)
  import FoundationModels
#endif

// MARK: - Generable Output Types (iOS 26+)

#if canImport(FoundationModels)
  @available(iOS 26.0, *)
  @Generable
  struct DetectedPattern: Sendable {
    @Guide(description: "A short, evocative pattern title, 8 words or fewer")
    var title: String

    @Guide(
      description: "Internal category for pattern type",
      .anyOf([
        "arc_phase", "drift", "crest", "fracture",
        "loop", "fade", "threshold", "resonance",
      ])
    )
    var category: String

    @Guide(description: "A warm 1-2 sentence observation in plain language, no technical terms")
    var observation: String

    @Guide(
      description: "How strong this pattern signal is",
      .anyOf(["strong", "emerging", "fading"])
    )
    var strength: String
  }

  @available(iOS 26.0, *)
  @Generable
  struct DriftAnalysis: Sendable {
    @Guide(
      description: "Overall alignment rating between behavior and stated purpose",
      .anyOf(["aligned", "drifting", "misaligned"])
    )
    var alignment: String

    @Guide(
      description: "A single warm sentence naming the core tension or harmony, in plain language")
    var headline: String

    @Guide(
      description:
        "2-3 sentences in plain language explaining what's aligned or off. No technical terms."
    )
    var explanation: String

    @Guide(
      description:
        "One simple, concrete action anyone could understand"
    )
    var suggestion: String
  }

  @available(iOS 26.0, *)
  @Generable
  struct WeeklyRecapOutput: Sendable {
    @Guide(description: "1-line warm summary of the week using their actual numbers")
    var headline: String

    @Guide(description: "The week's biggest positive moment in plain language")
    var win: String

    @Guide(description: "One thing to watch in plain, honest language")
    var watchArea: String

    @Guide(
      description:
        "A short, memorable closing that echoes their anchor, like texting a close friend")
    var closing: String
  }
#endif

// MARK: - Platform-Agnostic Result Types (work on all iOS versions)

struct PatternResult: Identifiable, Sendable {
  let id = UUID()
  let title: String
  let category: String
  let observation: String
  let strength: String

  var strengthColor: String {
    switch strength {
    case "strong": "green"
    case "emerging": "orange"
    case "fading": "gray"
    default: "blue"
    }
  }

  var categoryEmoji: String {
    switch category {
    case "arc_phase": "🌀"  // 𝒰 Becoming
    case "drift": "〰️"  // δ drift wave
    case "crest": "🏔️"  // κ peak
    case "fracture": "⚡"  // Δ break
    case "loop": "🔄"  // λ cycle
    case "fade": "🌅"  // ϝ dissolution
    case "threshold": "🚪"  // Θ gate
    case "resonance": "🎵"  // ℜ harmony
    default: "📊"
    }
  }
}

struct DriftResult: Sendable {
  let alignment: String
  let headline: String
  let explanation: String
  let suggestion: String

  var alignmentEmoji: String {
    switch alignment {
    case "aligned": "✅"
    case "drifting": "⚠️"
    case "misaligned": "🔴"
    default: "📊"
    }
  }

  var isAligned: Bool { alignment == "aligned" }
}

struct RecapResult: Sendable {
  let headline: String
  let win: String
  let watchArea: String
  let closing: String
}

// MARK: - Intelligence Manager

/// Central AI layer: uses Apple Foundation Models on-device (iOS 26+),
/// with graceful fallback to mock data on older iOS and Simulator.
@MainActor
final class IntelligenceManager: ObservableObject {
  @Published var isAvailable = false
  @Published var isProcessing = false

  init() {
    checkAvailability()
  }

  func checkAvailability() {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        #if targetEnvironment(simulator)
          isAvailable = false
        #else
          isAvailable = SystemLanguageModel.default.availability == .available
        #endif
      } else {
        isAvailable = false
      }
    #else
      isAvailable = false
    #endif
  }

  // MARK: - Pattern Detection

  func detectPatterns(
    journalBodies: [String],
    flameScores: [(date: String, score: Int)],
    moods: [String]
  ) async -> [PatternResult] {
    isProcessing = true
    defer { isProcessing = false }

    #if canImport(FoundationModels)
      if #available(iOS 26.0, *), isAvailable {
        do {
          let prompt = buildPatternPrompt(
            journals: journalBodies,
            flames: flameScores,
            moods: moods
          )

          let session = LanguageModelSession(instructions: patternInstructions)
          let result = try await session.respond(
            to: prompt,
            generating: [DetectedPattern].self
          )
          let response = result.content

          return response.map { pattern in
            PatternResult(
              title: pattern.title,
              category: pattern.category,
              observation: pattern.observation,
              strength: pattern.strength
            )
          }
        } catch {
          return mockPatterns()
        }
      }
    #endif

    try? await Task.sleep(for: .seconds(0.5))
    return mockPatterns()
  }

  // MARK: - Drift Detection

  func detectDrift(
    devotionAnchor: String,
    recentJournals: [String],
    flameAverage: Double,
    currentPhase: String,
    personalityTone: String
  ) async -> DriftResult {
    isProcessing = true
    defer { isProcessing = false }

    #if canImport(FoundationModels)
      if #available(iOS 26.0, *), isAvailable {
        do {
          let prompt = buildDriftPrompt(
            anchor: devotionAnchor,
            journals: recentJournals,
            flameAvg: flameAverage,
            phase: currentPhase,
            tone: personalityTone
          )

          let session = LanguageModelSession(instructions: driftInstructions)
          let result = try await session.respond(
            to: prompt,
            generating: DriftAnalysis.self
          )
          let response = result.content

          return DriftResult(
            alignment: response.alignment,
            headline: response.headline,
            explanation: response.explanation,
            suggestion: response.suggestion
          )
        } catch {
          return mockDrift()
        }
      }
    #endif

    try? await Task.sleep(for: .seconds(0.5))
    return mockDrift()
  }

  // MARK: - Weekly Recap

  func generateRecap(
    devotionAnchor: String,
    patterns: [PatternResult],
    drift: DriftResult,
    flameAverage: Double,
    habitCompletionRate: Double
  ) async -> RecapResult {
    isProcessing = true
    defer { isProcessing = false }

    #if canImport(FoundationModels)
      if #available(iOS 26.0, *), isAvailable {
        do {
          let prompt = buildRecapPrompt(
            anchor: devotionAnchor,
            patterns: patterns,
            drift: drift,
            flameAvg: flameAverage,
            habitRate: habitCompletionRate
          )

          let session = LanguageModelSession(instructions: recapInstructions)
          let result = try await session.respond(
            to: prompt,
            generating: WeeklyRecapOutput.self
          )
          let response = result.content

          return RecapResult(
            headline: response.headline,
            win: response.win,
            watchArea: response.watchArea,
            closing: response.closing
          )
        } catch {
          return mockRecap()
        }
      }
    #endif

    try? await Task.sleep(for: .seconds(0.5))
    return mockRecap()
  }
}
