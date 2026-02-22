import Charts
import SwiftUI

/// Donut chart showing mood distribution over a selected period.
struct MoodRingChart: View {
  let slices: [InsightsEngine.MoodSlice]

  var body: some View {
    if slices.isEmpty {
      emptyState
    } else {
      chartContent
    }
  }

  private var emptyState: some View {
    VStack(spacing: 8) {
      Image(systemName: "chart.pie")
        .font(.largeTitle)
        .foregroundStyle(Color.gray.opacity(0.3))
      Text("Journal more to see your mood patterns")
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
    .frame(height: 180)
    .frame(maxWidth: .infinity)
  }

  private var chartContent: some View {
    HStack(spacing: 20) {
      Chart(slices) { slice in
        SectorMark(
          angle: .value("Count", slice.count),
          innerRadius: .ratio(0.6),
          angularInset: 2
        )
        .foregroundStyle(slice.mood.color)
        .cornerRadius(4)
      }
      .frame(width: 140, height: 140)

      VStack(alignment: .leading, spacing: 6) {
        ForEach(slices) { slice in
          HStack(spacing: 6) {
            Circle()
              .fill(slice.mood.color)
              .frame(width: 8, height: 8)
            Text(slice.mood.emoji)
              .font(.caption)
            Text(slice.mood.label)
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Text("\(Int(slice.percentage * 100))%")
              .font(.caption.weight(.semibold).monospacedDigit())
              .foregroundStyle(.primary)
          }
        }
      }
    }
  }
}
