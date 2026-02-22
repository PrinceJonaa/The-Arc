import SwiftUI

/// Horizontal bar chart showing each habit's completion rate.
struct HabitScorecardView: View {
  let scores: [InsightsEngine.HabitScore]

  var body: some View {
    if scores.isEmpty {
      emptyState
    } else {
      scoreList
    }
  }

  private var emptyState: some View {
    VStack(spacing: 8) {
      Image(systemName: "checkmark.circle")
        .font(.largeTitle)
        .foregroundStyle(Color.gray.opacity(0.3))
      Text("Add habits to see your scorecard")
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
  }

  private var scoreList: some View {
    VStack(spacing: 10) {
      ForEach(scores) { score in
        scoreRow(score: score)
      }
    }
  }

  private func scoreRow(score: InsightsEngine.HabitScore) -> some View {
    VStack(spacing: 4) {
      HStack {
        Text(score.emoji)
          .font(.caption)
        Text(score.name)
          .font(.caption.weight(.medium))
          .foregroundStyle(.primary)
          .lineLimit(1)
        Spacer()
        Text("\(Int(score.completionRate * 100))%")
          .font(.caption.weight(.semibold).monospacedDigit())
          .foregroundStyle(.primary)
        if score.streak >= 1 {
          HStack(spacing: 2) {
            Image(systemName: "flame.fill")
              .font(.caption2)
              .foregroundStyle(.orange)
            Text("\(score.streak)")
              .font(.caption2.weight(.medium))
              .foregroundStyle(.secondary)
          }
        }
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule(style: .continuous)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 6)

          Capsule(style: .continuous)
            .fill(barColor(for: score.completionRate))
            .frame(
              width: geo.size.width * score.completionRate,
              height: 6
            )
        }
      }
      .frame(height: 6)
    }
  }

  private func barColor(for rate: Double) -> Color {
    switch rate {
    case 0.8...: .green
    case 0.5..<0.8: .blue
    case 0.25..<0.5: .orange
    default: .red
    }
  }
}
