import SwiftUI

struct JournalEntryRow: View {
  let entry: JournalEntry

  var body: some View {
    HStack(spacing: 12) {
      // Mood indicator
      Text(entry.mood.emoji)
        .font(.title2)
        .frame(width: 44, height: 44)
        .background {
          Circle()
            .fill(entry.mood.color.opacity(0.15))
        }

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          if !entry.title.isEmpty {
            Text(entry.title)
              .font(.body.weight(.medium))
              .foregroundStyle(.primary)
              .lineLimit(1)
          }

          // Prompt type badge
          if entry.promptType != .free {
            promptBadge
          }

          Spacer()

          Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
            .font(.caption)
            .foregroundStyle(.tertiary)
        }

        if !entry.body.isEmpty {
          Text(entry.snippet)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }
      }
    }
    .padding()
    .adaptiveGlass()
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "\(entry.mood.label) mood. \(entry.title). \(entry.snippet)"
    )
  }

  private var promptBadge: some View {
    HStack(spacing: 3) {
      Image(systemName: entry.promptType == .mirror ? "mic.fill" : entry.promptType.systemImage)
        .font(.caption2)
      Text(entry.promptType.label)
        .font(.caption2)
    }
    .foregroundStyle(.purple)
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background {
      Capsule(style: .continuous)
        .fill(Color.purple.opacity(0.12))
    }
  }
}
