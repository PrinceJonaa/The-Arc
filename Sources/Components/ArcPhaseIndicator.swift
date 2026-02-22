import SwiftUI

/// Horizontal capsule-chain showing 9 arc phases, current phase highlighted with glow.
struct ArcPhaseIndicator: View {
  let currentPhase: ArcPhase
  var compact: Bool = false

  var body: some View {
    if compact {
      compactView
    } else {
      fullView
    }
  }

  private var compactView: some View {
    HStack(spacing: 3) {
      ForEach(ArcPhase.allCases) { phase in
        let isCurrent = phase == currentPhase
        let isPast = phase.ordinal < currentPhase.ordinal

        Capsule(style: .continuous)
          .fill(capsuleColor(isCurrent: isCurrent, isPast: isPast, phase: phase))
          .frame(height: 6)
          .shadow(
            color: isCurrent ? phase.color.opacity(0.5) : .clear,
            radius: isCurrent ? 4 : 0
          )
      }
    }
    .accessibilityLabel("Phase \(currentPhase.ordinal + 1) of 9: \(currentPhase.label)")
  }

  private var fullView: some View {
    VStack(spacing: 12) {
      // Phase capsules
      HStack(spacing: 3) {
        ForEach(ArcPhase.allCases) { phase in
          let isCurrent = phase == currentPhase
          let isPast = phase.ordinal < currentPhase.ordinal

          VStack(spacing: 4) {
            Capsule(style: .continuous)
              .fill(capsuleColor(isCurrent: isCurrent, isPast: isPast, phase: phase))
              .frame(height: 8)
              .shadow(
                color: isCurrent ? phase.color.opacity(0.5) : .clear,
                radius: isCurrent ? 6 : 0
              )

            if isCurrent {
              Text(phase.emoji)
                .font(.caption)
                .transition(.scale.combined(with: .opacity))
            }
          }
        }
      }

      // Current phase label
      HStack(spacing: 6) {
        Text(currentPhase.emoji)
          .font(.body)
        Text(currentPhase.label)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(currentPhase.color)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Phase \(currentPhase.ordinal + 1) of 9: \(currentPhase.label)")
  }

  private func capsuleColor(isCurrent: Bool, isPast: Bool, phase: ArcPhase) -> Color {
    if isCurrent {
      return phase.color
    } else if isPast {
      return phase.color.opacity(0.4)
    } else {
      return Color.gray.opacity(0.2)
    }
  }
}

#Preview {
  VStack(spacing: 40) {
    ArcPhaseIndicator(currentPhase: .trials)
    ArcPhaseIndicator(currentPhase: .revelation, compact: true)
  }
  .padding()
}
