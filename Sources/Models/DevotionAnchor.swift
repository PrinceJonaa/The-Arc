import Foundation
import SwiftData

/// The devotion anchor — the axis everything else is measured against.
///
/// > "What is the thing that, even when everything around you is chaos,
/// > still feels like it belongs to you?"
@Model
final class DevotionAnchor {
  var id: UUID
  var statement: String
  var createdAt: Date
  var lastRevisedAt: Date

  init(statement: String) {
    self.id = UUID()
    self.statement = statement
    self.createdAt = .now
    self.lastRevisedAt = .now
  }

  /// Whether the anchor should be revisited (quarterly).
  var needsRevision: Bool {
    let calendar = Calendar.current
    guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: .now) else {
      return false
    }
    return lastRevisedAt < threeMonthsAgo
  }
}
