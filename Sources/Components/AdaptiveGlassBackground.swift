import SwiftUI

/// A view modifier that applies an adaptive glass background,
/// switching to a solid fill when transparency is reduced or
/// the device is in Low Power Mode.
struct AdaptiveGlassBackground: ViewModifier {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  let cornerRadius: CGFloat
  let material: Material

  init(cornerRadius: CGFloat = 16, material: Material = .regularMaterial) {
    self.cornerRadius = cornerRadius
    self.material = material
  }

  private var useSolidFallback: Bool {
    reduceTransparency || ProcessInfo.processInfo.isLowPowerModeEnabled
  }

  func body(content: Content) -> some View {
    content
      .background {
        if useSolidFallback {
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.secondarySystemBackground))
        } else {
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(material)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
            .overlay {
              RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
            }
        }
      }
  }
}

extension View {
  /// Applies an adaptive glass background with automatic accessibility
  /// and performance fallbacks.
  func adaptiveGlass(
    cornerRadius: CGFloat = 16,
    material: Material = .regularMaterial
  ) -> some View {
    modifier(AdaptiveGlassBackground(cornerRadius: cornerRadius, material: material))
  }
}
