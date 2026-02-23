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

  @StateObject private var voiceEngine = VoiceJournalEngine()
  @State private var voicePermissionGranted = false

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

          // Inline mic button
          HStack {
            Spacer()

            Button {
              toggleVoiceInput()
            } label: {
              HStack(spacing: 8) {
                Image(systemName: voiceEngine.isRecording ? "mic.fill" : "mic")
                  .font(.body.weight(.medium))
                  .foregroundStyle(voiceEngine.isRecording ? .red : .blue)

                if voiceEngine.isRecording {
                  // Audio level indicator
                  RoundedRectangle(cornerRadius: 2)
                    .fill(.red.opacity(0.6))
                    .frame(width: max(4, CGFloat(voiceEngine.audioLevel) * 60), height: 8)
                    .animation(.easeInOut(duration: 0.1), value: voiceEngine.audioLevel)

                  Text("Tap to stop")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
              }
              .padding(.vertical, 8)
              .padding(.horizontal, 12)
              .background {
                Capsule()
                  .fill(voiceEngine.isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.08))
              }
            }
            .buttonStyle(.plain)

            Spacer()
          }
          .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
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
          Button("Cancel") {
            voiceEngine.stopRecording()
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(isEditing ? "Save" : "Done") {
            voiceEngine.stopRecording()
            appendVoiceIfNeeded()
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
      .task {
        voicePermissionGranted = await voiceEngine.requestPermissions()
      }
      .onChange(of: voiceEngine.liveTranscript) {
        // Live preview of voice input (don't append until stopped)
      }
    }
  }

  // MARK: - Voice Input

  private func toggleVoiceInput() {
    if voiceEngine.isRecording {
      // Append transcription and stop
      appendVoiceIfNeeded()
      voiceEngine.stopRecording()
    } else {
      // Clear the engine's buffer and start fresh
      voiceEngine.liveTranscript = ""
      try? voiceEngine.startRecording()
    }
  }

  private func appendVoiceIfNeeded() {
    let transcript = voiceEngine.liveTranscript
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !transcript.isEmpty else { return }

    if entryBody.isEmpty {
      entryBody = transcript
    } else {
      entryBody += "\n\n" + transcript
    }
    voiceEngine.liveTranscript = ""
  }

  // MARK: - Save

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
