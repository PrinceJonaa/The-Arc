import SwiftUI

/// A reusable glass card component following iOS 26 Liquid Glass design.
///
/// Automatically falls back to a solid background when the user enables
/// Reduce Transparency or the device is in Low Power Mode.
struct GlassCard<Content: View>: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding()
      .background {
        if reduceTransparency || ProcessInfo.processInfo.isLowPowerModeEnabled {
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.secondarySystemBackground))
        } else {
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
            .overlay {
              RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                  LinearGradient(
                    colors: [.white.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ),
                  lineWidth: 1
                )
            }
        }
      }
  }
}

#Preview {
  GlassCard {
    Text("Preview Card")
      .font(.headline)
  }
  .padding()
}
