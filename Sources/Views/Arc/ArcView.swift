import SwiftData
import SwiftUI

/// The Arc tab: Growth Chart (top) + Journey Map (bottom).
struct ArcView: View {
  @Query(sort: \DevotionAnchor.createdAt, order: .reverse)
  private var anchors: [DevotionAnchor]

  private var currentAnchor: DevotionAnchor? { anchors.first }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // Devotion anchor card
          if let anchor = currentAnchor {
            devotionCard(anchor: anchor)
          }

          // Growth chart
          GlassCard {
            GrowthChartView()
          }

          // Journey map
          GlassCard {
            JourneyMapView()
          }
        }
        .padding()
      }
      .navigationTitle("Your Arc")
    }
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
