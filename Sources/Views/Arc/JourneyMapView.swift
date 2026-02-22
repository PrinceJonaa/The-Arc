import SwiftData
import SwiftUI

/// Visual journey map showing current arc phase, 5-year vision, and 10-year calling.
struct JourneyMapView: View {
  @Query private var profiles: [UserProfile]

  @State private var showVisionEditor = false

  private var profile: UserProfile? { profiles.first }

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      phaseSection
      visionSection
    }
  }

  private var phaseSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Your Journey")
        .font(.headline.weight(.semibold))
        .foregroundStyle(.primary)

      if let profile {
        ArcPhaseIndicator(currentPhase: profile.currentPhase)

        Text(profile.currentPhase.description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.top, 4)
      } else {
        ArcPhaseIndicator(currentPhase: .ignition)
      }
    }
  }

  private var visionSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Vision")
          .font(.headline.weight(.semibold))
          .foregroundStyle(.primary)
        Spacer()
        Button {
          showVisionEditor = true
        } label: {
          Label("Edit", systemImage: "pencil")
            .font(.caption)
        }
      }

      VStack(spacing: 12) {
        visionRow(
          icon: "5.circle.fill",
          label: "5-Year Vision",
          text: profile?.fiveYearVision ?? "",
          placeholder: "Where do you see yourself in 5 years?"
        )

        visionRow(
          icon: "10.circle.fill",
          label: "10-Year Calling",
          text: profile?.tenYearCalling ?? "",
          placeholder: "What would you still do if nothing external validated it?"
        )
      }
    }
    .sheet(isPresented: $showVisionEditor) {
      VisionEditorSheet()
    }
  }

  private func visionRow(
    icon: String,
    label: String,
    text: String,
    placeholder: String
  ) -> some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundStyle(.blue)
        .frame(width: 28)

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)

        if text.isEmpty {
          Text(placeholder)
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            .italic()
        } else {
          Text(text)
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .adaptiveGlass(cornerRadius: 12)
  }
}
