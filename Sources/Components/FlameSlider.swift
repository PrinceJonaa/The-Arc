import SwiftUI

/// Custom 0–10 slider with animated flame that grows/changes color with score.
struct FlameSlider: View {
  @Binding var score: Int

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var flameSize: CGFloat {
    CGFloat(20 + score * 3)
  }

  private var flameColor: Color {
    switch score {
    case 0...2: .gray
    case 3...4: .orange.opacity(0.6)
    case 5...6: .orange
    case 7...8: .red
    case 9...10: .yellow
    default: .orange
    }
  }

  var body: some View {
    VStack(spacing: 16) {
      // Flame
      Image(systemName: "flame.fill")
        .font(.system(size: flameSize))
        .foregroundStyle(flameColor)
        .shadow(color: flameColor.opacity(0.4), radius: score >= 7 ? 10 : 0)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.6), value: score)
        .accessibilityHidden(true)

      // Score label
      Text("\(score)")
        .font(.system(.title, design: .rounded, weight: .bold))
        .foregroundStyle(.primary)
        .contentTransition(.numericText())

      // Slider
      Slider(
        value: Binding(
          get: { Double(score) },
          set: { newValue in
            let newScore = Int(newValue.rounded())
            if newScore != score {
              let impact = UIImpactFeedbackGenerator(style: .light)
              impact.impactOccurred()
              score = newScore
            }
          }
        ),
        in: 0...10,
        step: 1
      )
      .tint(flameColor)
    }
    .accessibilityValue("\(score) out of 10")
  }
}

#Preview {
  struct Preview: View {
    @State var score = 7
    var body: some View {
      FlameSlider(score: $score)
        .padding()
    }
  }
  return Preview()
}
