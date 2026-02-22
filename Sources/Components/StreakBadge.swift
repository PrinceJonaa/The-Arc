import SwiftUI

/// Flame icon with streak count and animated glow.
struct StreakBadge: View {
  let count: Int

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isGlowing = false

  private var isActive: Bool { count >= 1 }

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "flame.fill")
        .foregroundStyle(isActive ? Color.orange : Color.gray)
        .font(.subheadline.weight(.semibold))
        .shadow(
          color: isActive ? .orange.opacity(isGlowing ? 0.6 : 0.2) : .clear,
          radius: isGlowing ? 6 : 2
        )

      Text("\(count)")
        .font(.subheadline.weight(.bold))
        .foregroundStyle(isActive ? Color.primary : Color.secondary)
        .contentTransition(.numericText())
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background {
      Capsule(style: .continuous)
        .fill(isActive ? Color.orange.opacity(0.15) : Color.gray.opacity(0.15))
    }
    .onAppear {
      guard isActive, !reduceMotion else { return }
      withAnimation(
        .easeInOut(duration: 1.5)
          .repeatForever(autoreverses: true)
      ) {
        isGlowing = true
      }
    }
    .accessibilityLabel("\(count) day streak")
  }
}

#Preview {
  HStack(spacing: 16) {
    StreakBadge(count: 0)
    StreakBadge(count: 7)
    StreakBadge(count: 30)
  }
  .padding()
}
