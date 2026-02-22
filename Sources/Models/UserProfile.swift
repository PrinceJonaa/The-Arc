import Foundation
import SwiftData

/// The user's personality tone — how the app speaks to them.
enum PersonalityTone: String, Codable, CaseIterable, Identifiable {
  case builder
  case dreamer
  case heartLed
  case systemsThinker
  case expressive

  var id: String { rawValue }

  var label: String {
    switch self {
    case .builder: "Builder"
    case .dreamer: "Dreamer"
    case .heartLed: "Heart-Led"
    case .systemsThinker: "Systems Thinker"
    case .expressive: "Expressive"
    }
  }

  var description: String {
    switch self {
    case .builder:
      "Direct, numbered, tactical. You want the actionable truth."
    case .dreamer:
      "Poetic, expansive, visionary. You think in possibility."
    case .heartLed:
      "Relational, soul-level. You feel your way to truth."
    case .systemsThinker:
      "Structured, framework-style. You map before you move."
    case .expressive:
      "Warm, celebratory, alive. You speak your truth loudly."
    }
  }

  var emoji: String {
    switch self {
    case .builder: "🔨"
    case .dreamer: "🌌"
    case .heartLed: "💛"
    case .systemsThinker: "🧩"
    case .expressive: "🎭"
    }
  }
}

@Model
final class UserProfile {
  var id: UUID
  var currentPhaseRaw: String
  var fiveYearVision: String
  var tenYearCalling: String
  var personalityToneRaw: String
  var onboardingCompletedAt: Date?
  var lastCalibratedAt: Date?

  init(
    currentPhase: ArcPhase = .ignition,
    personalityTone: PersonalityTone = .builder
  ) {
    self.id = UUID()
    self.currentPhaseRaw = currentPhase.rawValue
    self.fiveYearVision = ""
    self.tenYearCalling = ""
    self.personalityToneRaw = personalityTone.rawValue
    self.onboardingCompletedAt = nil
    self.lastCalibratedAt = nil
  }

  var currentPhase: ArcPhase {
    get { ArcPhase(rawValue: currentPhaseRaw) ?? .ignition }
    set { currentPhaseRaw = newValue.rawValue }
  }

  var personalityTone: PersonalityTone {
    get { PersonalityTone(rawValue: personalityToneRaw) ?? .builder }
    set { personalityToneRaw = newValue.rawValue }
  }

  var hasCompletedOnboarding: Bool {
    onboardingCompletedAt != nil
  }

  /// Whether 30+ days have passed since last calibration.
  var needsRecalibration: Bool {
    guard hasCompletedOnboarding else { return false }
    let anchor = lastCalibratedAt ?? onboardingCompletedAt ?? .now
    let daysSince =
      Calendar.current.dateComponents(
        [.day], from: anchor, to: .now
      ).day ?? 0
    return daysSince >= 30
  }
}
