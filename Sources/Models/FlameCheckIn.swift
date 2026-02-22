import Foundation
import SwiftData

/// Daily flame check-in: How aligned does today feel with why you started? (0–10)
@Model
final class FlameCheckIn {
  var id: UUID
  var date: Date
  var score: Int
  var intention: String
  var reflectionPrompt: String
  var reflectionResponse: String
  var createdAt: Date

  init(
    date: Date = .now,
    score: Int = 5,
    intention: String = "",
    reflectionPrompt: String = "",
    reflectionResponse: String = ""
  ) {
    self.id = UUID()
    self.date = Calendar.current.startOfDay(for: date)
    self.score = min(max(score, 0), 10)
    self.intention = intention
    self.reflectionPrompt = reflectionPrompt
    self.reflectionResponse = reflectionResponse
    self.createdAt = .now
  }

  /// Flame label for the current score.
  var flameLabel: String {
    switch score {
    case 0...2: "Flickering"
    case 3...4: "Dim"
    case 5...6: "Steady"
    case 7...8: "Burning"
    case 9...10: "Blazing"
    default: "Steady"
    }
  }
}
