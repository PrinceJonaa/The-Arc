import SwiftData
import SwiftUI

/// Daily flame check-in card: "How aligned does today feel?"
struct FlameCheckInCard: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \FlameCheckIn.date, order: .reverse)
  private var checkIns: [FlameCheckIn]

  @State private var score: Int = 5
  @State private var hasCheckedInToday = false

  private var todayCheckIn: FlameCheckIn? {
    checkIns.first { Calendar.current.isDateInToday($0.date) }
  }

  var body: some View {
    GlassCard {
      VStack(spacing: 14) {
        HStack {
          Text("🔥")
            .font(.title2)
          Text("Daily Flame")
            .font(.headline.weight(.semibold))
            .foregroundStyle(.primary)
          Spacer()
          if let checkIn = todayCheckIn {
            Text(checkIn.flameLabel)
              .font(.caption.weight(.medium))
              .foregroundStyle(.secondary)
          }
        }

        if hasCheckedInToday, let checkIn = todayCheckIn {
          checkedInView(checkIn: checkIn)
        } else {
          checkInView
        }
      }
    }
    .onAppear {
      if let existing = todayCheckIn {
        score = existing.score
        hasCheckedInToday = true
      }
    }
  }

  private var checkInView: some View {
    VStack(spacing: 12) {
      Text("How aligned does today feel with why you started?")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      FlameSlider(score: $score)

      Button {
        saveCheckIn()
      } label: {
        Text("Lock In")
          .font(.subheadline.weight(.semibold))
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.regular)
    }
  }

  private func checkedInView(checkIn: FlameCheckIn) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "flame.fill")
        .font(.title)
        .foregroundStyle(flameColor(for: checkIn.score))

      VStack(alignment: .leading, spacing: 2) {
        Text("\(checkIn.score)/10")
          .font(.title3.weight(.bold))
          .foregroundStyle(.primary)
        Text("Checked in today")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      if checkIn.score <= 4 {
        Text(ReflectionPrompts.randomDipRecovery())
          .font(.caption2)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.trailing)
          .frame(maxWidth: 140)
      }
    }
  }

  private func flameColor(for score: Int) -> Color {
    switch score {
    case 0...2: .gray
    case 3...4: .orange.opacity(0.6)
    case 5...6: .orange
    case 7...8: .red
    default: .yellow
    }
  }

  private func saveCheckIn() {
    let today = Calendar.current.startOfDay(for: .now)
    let prompt = ReflectionPrompts.dailyPrompt()

    if let existing = todayCheckIn {
      existing.score = score
    } else {
      let checkIn = FlameCheckIn(
        date: today,
        score: score,
        reflectionPrompt: prompt
      )
      modelContext.insert(checkIn)
    }

    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      hasCheckedInToday = true
    }
  }
}
