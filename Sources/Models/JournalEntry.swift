import Foundation
import SwiftData

@Model
final class JournalEntry {
  var id: UUID
  var date: Date
  var title: String
  var body: String
  var moodRaw: String
  var createdAt: Date
  var updatedAt: Date

  init(
    title: String = "",
    body: String = "",
    mood: Mood = .okay,
    date: Date = .now
  ) {
    self.id = UUID()
    self.date = Calendar.current.startOfDay(for: date)
    self.title = title
    self.body = body
    self.moodRaw = mood.rawValue
    self.createdAt = .now
    self.updatedAt = .now
  }

  var mood: Mood {
    get { Mood(rawValue: moodRaw) ?? .okay }
    set {
      moodRaw = newValue.rawValue
      updatedAt = .now
    }
  }

  /// First ~100 characters of the body for preview.
  var snippet: String {
    if body.count <= 100 { return body }
    return String(body.prefix(100)) + "…"
  }
}
