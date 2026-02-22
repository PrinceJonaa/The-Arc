import SwiftUI

/// Live breathing waveform visualizer driven by real microphone amplitude.
struct WaveformView: View {
  let audioLevel: Float
  let isRecording: Bool

  private let barCount = 40

  var body: some View {
    TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
      HStack(spacing: 3) {
        ForEach(0..<barCount, id: \.self) { index in
          WaveBar(
            audioLevel: audioLevel,
            index: index,
            time: timeline.date.timeIntervalSinceReferenceDate,
            isRecording: isRecording
          )
        }
      }
      .frame(height: 60)
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .adaptiveGlass(cornerRadius: 30)
    }
  }
}

private struct WaveBar: View {
  let audioLevel: Float
  let index: Int
  let time: Double
  let isRecording: Bool

  private var phase: Double { Double(index) * 0.3 }

  private var barHeight: CGFloat {
    guard isRecording else { return 4 }
    let wave = CGFloat(sin(time * 3 + phase)) * 0.3
    let audio = CGFloat(audioLevel) * 40
    return max(4, 4 + wave + audio)
  }

  var body: some View {
    RoundedRectangle(cornerRadius: 2, style: .continuous)
      .fill(
        LinearGradient(
          colors: [.white.opacity(0.9), .white.opacity(0.3)],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .frame(width: 3, height: barHeight)
      .animation(
        .spring(response: 0.15, dampingFraction: 0.6),
        value: barHeight
      )
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    WaveformView(audioLevel: 0.5, isRecording: true)
  }
}
