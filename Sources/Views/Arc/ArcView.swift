import SwiftData
import SwiftUI

/// The Arc tab: Devotion Anchor, Growth Chart, Journey Map, and Monthly Insights.
struct ArcView: View {
  @Query(sort: \DevotionAnchor.createdAt, order: .reverse)
  private var anchors: [DevotionAnchor]

  private var currentAnchor: DevotionAnchor? { anchors.first }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          if let anchor = currentAnchor {
            devotionCard(anchor: anchor)
          }

          GlassCard {
            GrowthChartView()
          }

          GlassCard {
            JourneyMapView()
          }

          insightsLink
        }
        .padding()
      }
      .navigationTitle("Your Arc")
      .navigationDestination(for: String.self) { dest in
        if dest == "insights" {
          InsightsView()
        }
      }
    }
  }

  private var insightsLink: some View {
    NavigationLink(value: "insights") {
      GlassCard {
        HStack {
          Image(systemName: "chart.bar.doc.horizontal")
            .font(.title3)
            .foregroundStyle(.blue)
          VStack(alignment: .leading, spacing: 2) {
            Text("Monthly Checkpoint")
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.primary)
            Text("Flame trends, mood patterns, habit scores")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
      }
    }
    .buttonStyle(.plain)
  }

  private func devotionCard(anchor: DevotionAnchor) -> some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "flame.circle.fill")
            .foregroundStyle(.orange)
          Text("Devotion Anchor")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
          Spacer()
          if anchor.needsRevision {
            Text("Revisit")
              .font(.caption2)
              .foregroundStyle(.orange)
              .padding(.horizontal, 8)
              .padding(.vertical, 3)
              .background {
                Capsule(style: .continuous)
                  .fill(Color.orange.opacity(0.15))
              }
          }
        }

        Text("\"\(anchor.statement)\"")
          .font(.subheadline.weight(.medium))
          .foregroundStyle(.primary)
          .italic()
      }
    }
  }
}

#Preview {
  ArcView()
    .modelContainer(
      for: [FlameCheckIn.self, UserProfile.self, DevotionAnchor.self],
      inMemory: true
    )
}
