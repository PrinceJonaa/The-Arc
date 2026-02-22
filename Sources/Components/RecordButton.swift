import SwiftUI

/// Pulsing microphone record button — breathes when active.
struct RecordButton: View {
  let isRecording: Bool
  let action: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    Button {
      let impact = UIImpactFeedbackGenerator(style: .heavy)
      impact.impactOccurred()
      action()
    } label: {
      ZStack {
        // Outer breathing ring
        Circle()
          .stroke(Color.red.opacity(isRecording ? 0.3 : 0), lineWidth: 8)
          .frame(width: 88, height: 88)
          .scaleEffect(isRecording ? 1.15 : 1.0)
          .animation(
            isRecording && !reduceMotion
              ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
              : .default,
            value: isRecording
          )

        // Core circle
        Circle()
          .fill(isRecording ? Color.red : Color.white)
          .frame(width: 72, height: 72)
          .overlay {
            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
              .font(.title2.weight(.semibold))
              .foregroundStyle(isRecording ? Color.white : Color.black)
          }
          .shadow(
            color: isRecording ? .red.opacity(0.4) : .black.opacity(0.2),
            radius: isRecording ? 16 : 8,
            y: 4
          )
      }
    }
    .buttonStyle(.plain)
    .scaleEffect(isRecording ? 1.05 : 1.0)
    .animation(
      .spring(response: 0.3, dampingFraction: 0.6),
      value: isRecording
    )
    .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    HStack(spacing: 32) {
      RecordButton(isRecording: false) {}
      RecordButton(isRecording: true) {}
    }
  }
}
