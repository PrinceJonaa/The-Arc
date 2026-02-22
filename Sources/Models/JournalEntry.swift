import Foundation
import SwiftData

/// Type of journal prompt that initiated the entry.
enum PromptType: String, Codable, CaseIterable, Identifiable {
  case free
  case reflection
  case mirror

  var id: String { rawValue }

  var label: String {
    switch self {
    case .free: "Free Write"
    case .reflection: "Reflection"
    case .mirror: "Mirror"
    }
  }

  var systemImage: String {
    switch self {
    case .free: "pencil.line"
    case .reflection: "sparkles"
    case .mirror: "person.crop.circle"
    }
  }
}

@Model
final class JournalEntry {
  var id: UUID
  var date: Date
  var title: String
  var body: String
  var moodRaw: String
  var promptTypeRaw: String
  var promptText: String
  var createdAt: Date
  var updatedAt: Date

  init(
    title: String = "",
    body: String = "",
    mood: Mood = .okay,
    promptType: PromptType = .free,
    promptText: String = "",
    date: Date = .now
  ) {
    self.id = UUID()
    self.date = Calendar.current.startOfDay(for: date)
    self.title = title
    self.body = body
    self.moodRaw = mood.rawValue
    self.promptTypeRaw = promptType.rawValue
    self.promptText = promptText
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

  var promptType: PromptType {
    get { PromptType(rawValue: promptTypeRaw) ?? .free }
    set { promptTypeRaw = newValue.rawValue }
  }

  /// First ~100 characters of the body for preview.
  var snippet: String {
    if body.count <= 100 { return body }
    return String(body.prefix(100)) + "…"
  }
}
