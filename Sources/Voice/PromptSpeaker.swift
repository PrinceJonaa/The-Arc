@preconcurrency import AVFoundation
import Foundation

/// Speaks prompts aloud using AVSpeechSynthesizer, paced to the user's personality tone.
@MainActor
final class PromptSpeaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
  @Published var isSpeaking = false

  nonisolated(unsafe) private let synthesizer = AVSpeechSynthesizer()
  private var onFinished: (() -> Void)?

  override init() {
    super.init()
    synthesizer.delegate = self
  }

  func speak(_ text: String, tone: PersonalityTone, onDone: (() -> Void)? = nil) {
    onFinished = onDone
    let utterance = AVSpeechUtterance(string: text)

    switch tone {
    case .dreamer:
      utterance.rate = 0.43
      utterance.pitchMultiplier = 1.1
    case .builder:
      utterance.rate = 0.52
      utterance.pitchMultiplier = 0.95
    case .expressive:
      utterance.rate = 0.50
      utterance.pitchMultiplier = 1.05
    case .heartLed:
      utterance.rate = 0.44
      utterance.pitchMultiplier = 1.08
    case .systemsThinker:
      utterance.rate = 0.50
      utterance.pitchMultiplier = 0.98
    }

    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    isSpeaking = true
    synthesizer.speak(utterance)
  }

  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
    isSpeaking = false
  }

  // MARK: - AVSpeechSynthesizerDelegate

  nonisolated func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    Task { @MainActor [weak self] in
      self?.isSpeaking = false
      self?.onFinished?()
    }
  }
}
