import SwiftData
import SwiftUI

struct JournalView: View {
  @Query(sort: \JournalEntry.date, order: .reverse)
  private var entries: [JournalEntry]

  @State private var showCompose = false

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
          EmptyStateView(
            systemImage: "book.closed",
            title: "No Journal Entries",
            subtitle: "Start writing to capture your thoughts and track your mood.",
            actionTitle: "Write Entry"
          ) {
            showCompose = true
          }
        } else {
          ScrollView {
            LazyVStack(spacing: 16) {
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
      .navigationTitle("Journal")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showCompose = true
          } label: {
            Label("New Entry", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showCompose) {
        ComposeJournalSheet()
      }
      .navigationDestination(for: JournalEntry.self) { entry in
        JournalEntryView(entry: entry)
      }
    }
  }
}

#Preview {
  JournalView()
    .modelContainer(for: JournalEntry.self, inMemory: true)
}
