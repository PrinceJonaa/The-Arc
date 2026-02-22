import SwiftData
import SwiftUI

/// Daily intention card tied to the user's stated mission.
struct DailyIntentionCard: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \FlameCheckIn.date, order: .reverse)
  private var checkIns: [FlameCheckIn]

  @State private var intention = ""
  @State private var isSaved = false

  private var todayCheckIn: FlameCheckIn? {
    checkIns.first { Calendar.current.isDateInToday($0.date) }
  }

  private var yesterdayCheckIn: FlameCheckIn? {
    checkIns.first { Calendar.current.isDateInYesterday($0.date) }
  }

  var body: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: "target")
            .foregroundStyle(.blue)
          Text("Daily Intention")
            .font(.headline.weight(.semibold))
            .foregroundStyle(.primary)
          Spacer()
        }

        // Today's reflection prompt
        Text(ReflectionPrompts.dailyPrompt())
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .italic()

        if let yesterday = yesterdayCheckIn, !yesterday.intention.isEmpty {
          HStack(spacing: 6) {
            Image(systemName: "arrow.turn.up.left")
              .font(.caption2)
              .foregroundStyle(.tertiary)
            Text("Yesterday: \(yesterday.intention)")
              .font(.caption)
              .foregroundStyle(.tertiary)
              .lineLimit(1)
          }
        }

        if isSaved {
          HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(.green)
            Text(intention)
              .font(.subheadline)
              .foregroundStyle(.primary)
          }
        } else {
          HStack {
            TextField("What's your intention today?", text: $intention)
              .font(.subheadline)
              .textFieldStyle(.plain)

            if !intention.trimmingCharacters(in: .whitespaces).isEmpty {
              Button {
                saveIntention()
              } label: {
                Image(systemName: "arrow.up.circle.fill")
                  .font(.title3)
                  .foregroundStyle(.blue)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(10)
          .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
              .fill(Color.gray.opacity(0.1))
          }
        }
      }
    }
    .onAppear {
      if let existing = todayCheckIn, !existing.intention.isEmpty {
        intention = existing.intention
        isSaved = true
      }
    }
  }

  private func saveIntention() {
    let trimmed = intention.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return }

    if let existing = todayCheckIn {
      existing.intention = trimmed
    } else {
      let checkIn = FlameCheckIn(
        score: 5,
        intention: trimmed,
        reflectionPrompt: ReflectionPrompts.dailyPrompt()
      )
      modelContext.insert(checkIn)
    }

    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      isSaved = true
    }

    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
  }
}
