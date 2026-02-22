import SwiftUI

/// Animated circular progress ring with iOS 26 glass center.
struct CircularProgress: View {
  let progress: Double
  let lineWidth: CGFloat
  let size: CGFloat
  let label: String?

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  init(
    progress: Double,
    lineWidth: CGFloat = 8,
    size: CGFloat = 120,
    label: String? = nil
  ) {
    self.progress = min(max(progress, 0), 1)
    self.lineWidth = lineWidth
    self.size = size
    self.label = label
  }

  var body: some View {
    ZStack {
      // Track
      Circle()
        .stroke(.quaternary, lineWidth: lineWidth)

      // Progress arc
      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          AngularGradient(
            colors: [.blue, .purple, .blue],
            center: .center
          ),
          style: StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round
          )
        )
        .rotationEffect(.degrees(-90))
        .animation(
          reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8),
          value: progress
        )

      // Center label
      if let label {
        Text(label)
          .font(.system(.title2, design: .rounded, weight: .bold))
          .foregroundStyle(.primary)
          .contentTransition(.numericText())
      }
    }
    .frame(width: size, height: size)
    .accessibilityValue("\(Int(progress * 100)) percent")
  }
}

#Preview {
  CircularProgress(progress: 0.72, label: "72%")
    .padding()
}
