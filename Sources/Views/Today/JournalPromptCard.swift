import SwiftData
import SwiftUI

struct JournalPromptCard: View {
  let todayEntry: JournalEntry?
  let onCompose: () -> Void

  var body: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: "book.closed.fill")
            .foregroundStyle(.purple)
          Text("Journal")
            .font(.headline.weight(.semibold))
            .foregroundStyle(.primary)
          Spacer()
        }

        if let entry = todayEntry {
          // Show today's entry preview
          HStack(spacing: 8) {
            Text(entry.mood.emoji)
              .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
              if !entry.title.isEmpty {
                Text(entry.title)
                  .font(.subheadline.weight(.medium))
                  .foregroundStyle(.primary)
                  .lineLimit(1)
              }
              Text(entry.snippet)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            }
          }
        } else {
          // Prompt to write
          Button(action: onCompose) {
            HStack {
              Image(systemName: "pencil.line")
                .foregroundStyle(.secondary)
              Text("How's your day going?")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
              Spacer()
            }
            .padding(12)
            .background {
              RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quaternary.opacity(0.3))
            }
          }
          .buttonStyle(.plain)
        }
      }
    }
  }
}
