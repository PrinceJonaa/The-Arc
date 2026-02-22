import SwiftData
import SwiftUI

struct ComposeJournalSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  var existingEntry: JournalEntry?
  var promptText: String?

  @State private var title = ""
  @State private var entryBody = ""
  @State private var mood: Mood = .okay
  @State private var date: Date = .now

  private var isEditing: Bool { existingEntry != nil }
  private var isMirrorPrompt: Bool { promptText != nil }

  var body: some View {
    NavigationStack {
      Form {
        Section("How are you feeling?") {
          MoodPicker(selected: $mood)
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }

        if let prompt = promptText {
          Section("Prompt") {
            Text(prompt)
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .italic()
          }
        }

        Section("Title") {
          TextField("Give it a title (optional)", text: $title)
        }

        Section("What's on your mind?") {
          TextEditor(text: $entryBody)
            .frame(minHeight: 200)
        }

        if !isEditing && !isMirrorPrompt {
          Section("Date") {
            DatePicker("Entry Date", selection: $date, displayedComponents: .date)
          }
        }
      }
      .navigationTitle(
        isEditing ? "Edit Entry" : (isMirrorPrompt ? "Mirror Reflection" : "New Entry")
      )
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(isEditing ? "Save" : "Done") {
            save()
            dismiss()
          }
          .fontWeight(.semibold)
        }
      }
      .onAppear {
        if let entry = existingEntry {
          title = entry.title
          entryBody = entry.body
          mood = entry.mood
          date = entry.date
        }
      }
    }
  }

  private func save() {
    let promptType: PromptType = isMirrorPrompt ? .mirror : .free

    if let entry = existingEntry {
      entry.title = title.trimmingCharacters(in: .whitespaces)
      entry.body = entryBody
      entry.mood = mood
      entry.updatedAt = .now
    } else {
      let entry = JournalEntry(
        title: title.trimmingCharacters(in: .whitespaces),
        body: entryBody,
        mood: mood,
        promptType: promptType,
        promptText: promptText ?? "",
        date: date
      )
      modelContext.insert(entry)
    }
  }
}

#Preview {
  ComposeJournalSheet()
    .modelContainer(for: JournalEntry.self, inMemory: true)
}
