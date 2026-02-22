import SwiftUI

/// Mood levels for journal entries, ordered from best to worst.
enum Mood: String, Codable, CaseIterable, Identifiable {
  case great
  case good
  case okay
  case rough
  case bad

  var id: String { rawValue }

  var emoji: String {
    switch self {
    case .great: "🌟"
    case .good: "😊"
    case .okay: "😐"
    case .rough: "😔"
    case .bad: "😞"
    }
  }

  var label: String {
    rawValue.capitalized
  }

  var systemImage: String {
    switch self {
    case .great: "sun.max.fill"
    case .good: "sun.min.fill"
    case .okay: "cloud.fill"
    case .rough: "cloud.rain.fill"
    case .bad: "cloud.bolt.fill"
    }
  }

  var color: Color {
    switch self {
    case .great: .yellow
    case .good: .green
    case .okay: .blue
    case .rough: .orange
    case .bad: .red
    }
  }
}
