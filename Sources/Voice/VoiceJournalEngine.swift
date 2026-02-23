@preconcurrency import AVFoundation
import Foundation
@preconcurrency import Speech

#if canImport(FoundationModels)
  import FoundationModels
#endif

/// On-device speech recognition engine powering the voice journal.
/// All recognition is on-device — no audio leaves the phone.
@MainActor
final class VoiceJournalEngine: ObservableObject {
  @Published var liveTranscript: String = ""
  @Published var audioLevel: Float = 0.0
  @Published var isRecording: Bool = false
  @Published var wordCount: Int = 0

  nonisolated(unsafe) private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  nonisolated(unsafe) private var recognitionTask: SFSpeechRecognitionTask?
  nonisolated(unsafe) private let audioEngine = AVAudioEngine()
  private let speechRecognizer = SFSpeechRecognizer(locale: .current)

  // MARK: - Permissions

  var isAvailable: Bool {
    speechRecognizer?.isAvailable ?? false
  }

  func requestPermissions() async -> Bool {
    let speechStatus = await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status)
      }
    }

    guard speechStatus == .authorized else { return false }

    let audioGranted = await AVAudioApplication.requestRecordPermission()
    return audioGranted
  }

  // MARK: - Recording

  func startRecording() throws {
    stopRecording()

    let request = SFSpeechAudioBufferRecognitionRequest()
    request.shouldReportPartialResults = true
    request.requiresOnDeviceRecognition = true
    recognitionRequest = request

    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.record, mode: .measurement, options: .duckOthers)
    try session.setActive(true, options: .notifyOthersOnDeactivation)

    let inputNode = audioEngine.inputNode
    let format = inputNode.outputFormat(forBus: 0)

    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
      self?.recognitionRequest?.append(buffer)
      self?.processAudioLevel(buffer: buffer)
    }

    recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, _ in
      guard let result else { return }
      Task { @MainActor [weak self] in
        self?.liveTranscript = result.bestTranscription.formattedString
        self?.wordCount = result.bestTranscription.segments.count
      }
    }

    audioEngine.prepare()
    try audioEngine.start()
    isRecording = true
  }

  func stopRecording() {
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
    recognitionRequest?.endAudio()
    recognitionTask?.cancel()
    recognitionRequest = nil
    recognitionTask = nil
    isRecording = false
    audioLevel = 0

    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  // MARK: - Audio Level

  private nonisolated func processAudioLevel(buffer: AVAudioPCMBuffer) {
    guard let channelData = buffer.floatChannelData?[0] else { return }
    let count = Int(buffer.frameLength)
    var sum: Float = 0
    for idx in 0..<count {
      let sample = channelData[idx]
      sum += sample * sample
    }
    let rms = sqrt(sum / Float(count))
    let level = min(rms * 10, 1.0)

    Task { @MainActor [weak self] in
      self?.audioLevel = level
    }
  }

  // MARK: - AI Organize

  /// Takes raw stream-of-consciousness transcript and organizes it
  /// into clear paragraphs, fixing filler words and run-ons.
  func organizeTranscript(_ raw: String) async -> String {
    guard !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return raw
    }

    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        do {
          let session = LanguageModelSession(
            instructions: """
              You clean up voice journal transcripts. The user spoke freely \
              and wants their thoughts organized.

              RULES:
              - Keep their exact words and voice — don't rewrite, just restructure.
              - Break into natural paragraphs by topic shift.
              - Remove filler words (um, uh, like, you know) only if excessive.
              - Fix obvious speech-to-text errors where meaning is clear.
              - Don't add anything they didn't say.
              - Don't summarize — keep the full thought.
              - Return ONLY the cleaned transcript, no commentary.
              """
          )

          let result = try await session.respond(
            to: "Clean up this voice journal transcript:\n\n\(raw)"
          )
          return result.content
        } catch {
          return basicOrganize(raw)
        }
      }
    #endif

    return basicOrganize(raw)
  }

  /// Simple paragraph splitting for non-AI fallback.
  private func basicOrganize(_ text: String) -> String {
    let sentences = text.components(separatedBy: ". ")
    var paragraphs: [String] = []
    var current: [String] = []

    for sentence in sentences {
      current.append(sentence)
      if current.count >= 3 {
        paragraphs.append(current.joined(separator: ". ") + ".")
        current = []
      }
    }
    if !current.isEmpty {
      let last = current.joined(separator: ". ")
      paragraphs.append(last.hasSuffix(".") ? last : last + ".")
    }

    return paragraphs.joined(separator: "\n\n")
  }
}
