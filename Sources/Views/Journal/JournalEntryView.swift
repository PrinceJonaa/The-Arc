import SwiftUI

struct JournalEntryView: View {
  @Bindable var entry: JournalEntry
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @State private var showEdit = false
  @State private var showDeleteConfirm = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Mood + Date header
        GlassCard {
          HStack {
            HStack(spacing: 10) {
              Text(entry.mood.emoji)
                .font(.title)

              VStack(alignment: .leading, spacing: 2) {
                Text(entry.mood.label)
                  .font(.headline)
                  .foregroundStyle(entry.mood.color)

                Text(entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                  .font(.caption)
                  .foregroundStyle(.tertiary)
              }
            }

            Spacer()
          }
        }

        // Title
        if !entry.title.isEmpty {
          Text(entry.title)
            .font(.title2.weight(.bold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 4)
        }

        // Body
        if !entry.body.isEmpty {
          Text(entry.body)
            .font(.body)
            .foregroundStyle(.primary)
            .lineSpacing(6)
            .padding(.horizontal, 4)
        }

        Spacer(minLength: 40)

        // Delete
        Button(role: .destructive) {
          showDeleteConfirm = true
        } label: {
          Label("Delete Entry", systemImage: "trash")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
      }
      .padding()
    }
    .navigationTitle(entry.title.isEmpty ? "Entry" : entry.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          showEdit = true
        } label: {
          Label("Edit", systemImage: "pencil")
        }
      }
    }
    .sheet(isPresented: $showEdit) {
      ComposeJournalSheet(existingEntry: entry)
    }
    .confirmationDialog(
      "Delete Entry",
      isPresented: $showDeleteConfirm,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        modelContext.delete(entry)
        dismiss()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This journal entry will be permanently deleted.")
    }
  }
}
