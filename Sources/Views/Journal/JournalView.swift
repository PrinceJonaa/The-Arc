import SwiftData
import SwiftUI

struct JournalView: View {
  @Query(sort: \JournalEntry.date, order: .reverse)
  private var entries: [JournalEntry]

  @State private var showCompose = false
  @State private var showVoiceJournal = false
  @State private var mirrorPromptText: String?
  @State private var voicePromptText: String?

  /// Group entries by month-year.
  private var groupedEntries: [(String, [JournalEntry])] {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"

    let grouped = Dictionary(grouping: entries) { entry in
      formatter.string(from: entry.date)
    }

    return grouped.sorted { first, second in
      guard let firstDate = first.value.first?.date,
        let secondDate = second.value.first?.date
      else {
        return false
      }
      return firstDate > secondDate
    }
  }

  var body: some View {
    NavigationStack {
      Group {
        if entries.isEmpty {
          emptyState
        } else {
          entryList
        }
      }
      .navigationTitle("Journal")
      .toolbar {
        ToolbarItemGroup(placement: .topBarTrailing) {
          // Voice entry
          Button {
            voicePromptText = nil
            showVoiceJournal = true
          } label: {
            Label("Voice Entry", systemImage: "mic.fill")
          }

          // Written entry
          Button {
            mirrorPromptText = nil
            showCompose = true
          } label: {
            Label("New Entry", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showCompose) {
        ComposeJournalSheet(promptText: mirrorPromptText)
      }
      .fullScreenCover(isPresented: $showVoiceJournal) {
        VoiceJournalView(
          prompt: voicePromptText,
          promptType: voicePromptText != nil ? .mirror : .free
        )
      }
      .navigationDestination(for: JournalEntry.self) { entry in
        JournalEntryView(entry: entry)
      }
    }
  }

  private var emptyState: some View {
    EmptyStateView(
      systemImage: "book.closed",
      title: "No Journal Entries",
      subtitle: "Write or speak to capture your thoughts.",
      actionTitle: "Voice Entry"
    ) {
      showVoiceJournal = true
    }
  }

  private var entryList: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        // Weekly Mirror Prompt
        MirrorPromptCard { prompt in
          voicePromptText = prompt
          showVoiceJournal = true
        }

        ForEach(groupedEntries, id: \.0) { month, monthEntries in
          Section {
            ForEach(monthEntries) { entry in
              NavigationLink(value: entry) {
                JournalEntryRow(entry: entry)
              }
              .buttonStyle(.plain)
            }
          } header: {
            Text(month)
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 4)
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  JournalView()
    .modelContainer(for: JournalEntry.self, inMemory: true)
}
