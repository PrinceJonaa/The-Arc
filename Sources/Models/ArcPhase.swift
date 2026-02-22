import SwiftUI

/// The 9 phases of the hero's journey — the structural arc of personal growth.
enum ArcPhase: String, Codable, CaseIterable, Identifiable {
  case ignition
  case departure
  case threshold
  case trials
  case abyss
  case revelation
  case transformation
  case command
  case radiance

  var id: String { rawValue }

  /// Display order (0-indexed).
  var ordinal: Int {
    switch self {
    case .ignition: 0
    case .departure: 1
    case .threshold: 2
    case .trials: 3
    case .abyss: 4
    case .revelation: 5
    case .transformation: 6
    case .command: 7
    case .radiance: 8
    }
  }

  var label: String {
    rawValue.capitalized
  }

  var emoji: String {
    switch self {
    case .ignition: "🔥"
    case .departure: "🚪"
    case .threshold: "🌊"
    case .trials: "⚔️"
    case .abyss: "🕳️"
    case .revelation: "💡"
    case .transformation: "🦋"
    case .command: "👑"
    case .radiance: "✨"
    }
  }

  var description: String {
    switch self {
    case .ignition:
      "Something in you says there's more. The spark has been lit."
    case .departure:
      "You've answered the call. The old world is behind you."
    case .threshold:
      "The first real test. Comfort zones are dissolving."
    case .trials:
      "Life is throwing everything at you. This is where most people quit."
    case .abyss:
      "The lowest point. The place where the old self dies so the new one can be born."
    case .revelation:
      "Clarity arrives. You see what you couldn't before."
    case .transformation:
      "You're becoming the person the journey was making. The change is real."
    case .command:
      "The skills, the mindset, the habits — they're yours now."
    case .radiance:
      "You are who you were called to be. Not perfect — radiant."
    }
  }

  var color: Color {
    switch self {
    case .ignition: .red
    case .departure: .orange
    case .threshold: .yellow
    case .trials: .mint
    case .abyss: .indigo
    case .revelation: .cyan
    case .transformation: .purple
    case .command: .blue
    case .radiance: .yellow
    }
  }
}
