@preconcurrency import AVFoundation
import Foundation
@preconcurrency import Speech

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
}
