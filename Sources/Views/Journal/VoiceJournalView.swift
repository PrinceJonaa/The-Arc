import SwiftData
import SwiftUI

/// Full-screen immersive voice recording view.
/// Words materialize in real time as the user speaks. Waveform pulses below.
struct VoiceJournalView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @Query private var profiles: [UserProfile]

  @StateObject private var engine = VoiceJournalEngine()
  @StateObject private var speaker = PromptSpeaker()

  @State private var hasPermission = false
  @State private var showPermissionAlert = false
  @State private var mood: Mood = .okay
  @State private var showMoodPicker = false

  /// Optional prompt for guided reflection.
  var prompt: String?
  var promptType: PromptType = .free

  private var profile: UserProfile? { profiles.first }

  var body: some View {
    ZStack {
      // Atmospheric background — subtle pulse with audio
      Color.black
        .opacity(0.88 + Double(engine.audioLevel) * 0.08)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: engine.audioLevel)

      VStack(spacing: 0) {
        topBar
        promptBanner
        transcriptArea
        wordCountBadge
        bottomControls
      }
    }
    .preferredColorScheme(.dark)
    .task {
      hasPermission = await engine.requestPermissions()
      if !hasPermission {
        showPermissionAlert = true
      }
    }
    .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
      Button("Open Settings") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }
      Button("Cancel", role: .cancel) { dismiss() }
    } message: {
      Text(
        "Voice journaling needs microphone and speech recognition access. Your voice never leaves your phone."
      )
    }
    .sheet(isPresented: $showMoodPicker) {
      saveMoodSheet
    }
  }

  // MARK: - Top Bar

  private var topBar: some View {
    HStack {
      Button {
        engine.stopRecording()
        speaker.stop()
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.body.weight(.semibold))
          .foregroundStyle(.white.opacity(0.7))
          .frame(width: 40, height: 40)
      }

      Spacer()

      if engine.isRecording {
        HStack(spacing: 6) {
          Circle()
            .fill(.red)
            .frame(width: 8, height: 8)
          Text("Recording")
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.7))
        }
      }

      Spacer()

      // Read prompt aloud button
      if prompt != nil {
        Button {
          readPromptAloud()
        } label: {
          Image(systemName: speaker.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
            .font(.body)
            .foregroundStyle(.white.opacity(0.7))
            .frame(width: 40, height: 40)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
  }

  // MARK: - Prompt Banner

  @ViewBuilder
  private var promptBanner: some View {
    if let prompt {
      Text(prompt)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.white.opacity(0.6))
        .italic()
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
  }

  // MARK: - Transcript

  private var transcriptArea: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(alignment: .leading) {
          Text(
            engine.liveTranscript.isEmpty
              ? "Start speaking…"
              : engine.liveTranscript
          )
          .font(.title3.weight(.medium))
          .foregroundStyle(
            engine.liveTranscript.isEmpty
              ? Color.white.opacity(0.25)
              : Color.white
          )
          .lineSpacing(8)
          .padding(24)
          .id("bottom")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .onChange(of: engine.wordCount) {
        withAnimation {
          proxy.scrollTo("bottom", anchor: .bottom)
        }
      }
    }
    .frame(maxHeight: .infinity)
  }

  // MARK: - Word Count

  @ViewBuilder
  private var wordCountBadge: some View {
    if engine.wordCount >= 1 {
      Text("\(engine.wordCount) words")
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.4))
        .padding(.bottom, 8)
        .transition(.opacity)
    }
  }

  // MARK: - Bottom Controls

  private var bottomControls: some View {
    VStack(spacing: 20) {
      WaveformView(
        audioLevel: engine.audioLevel,
        isRecording: engine.isRecording
      )

      HStack(spacing: 40) {
        // Cancel
        Button {
          engine.stopRecording()
          speaker.stop()
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background {
              Circle().fill(.ultraThinMaterial)
            }
        }

        // Mic button
        RecordButton(isRecording: engine.isRecording) {
          toggleRecording()
        }

        // Save
        Button {
          engine.stopRecording()
          showMoodPicker = true
        } label: {
          Image(systemName: "checkmark")
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background {
              Circle().fill(Color.blue)
            }
        }
        .disabled(engine.liveTranscript.isEmpty)
        .opacity(engine.liveTranscript.isEmpty ? 0.4 : 1.0)
      }
    }
    .padding(.horizontal, 24)
    .padding(.bottom, 44)
  }

  // MARK: - Mood Sheet

  private var saveMoodSheet: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Text("How does this feel?")
          .font(.headline)
          .foregroundStyle(.primary)

        MoodPicker(selected: $mood)

        Spacer()
      }
      .padding(24)
      .navigationTitle("Save Entry")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveEntry()
            showMoodPicker = false
            dismiss()
          }
          .fontWeight(.semibold)
        }
      }
    }
    .presentationDetents([.medium])
  }

  // MARK: - Actions

  private func toggleRecording() {
    if engine.isRecording {
      engine.stopRecording()
    } else {
      try? engine.startRecording()
    }
  }

  private func readPromptAloud() {
    guard let prompt else { return }
    let tone = profile?.personalityTone ?? .builder
    if speaker.isSpeaking {
      speaker.stop()
    } else {
      speaker.speak(prompt, tone: tone) {
        // Auto-start recording after prompt finishes
        try? engine.startRecording()
      }
    }
  }

  private func saveEntry() {
    let transcript = engine.liveTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !transcript.isEmpty else { return }

    let entry = JournalEntry(
      title: prompt != nil ? "Voice Reflection" : "Voice Entry",
      body: transcript,
      mood: mood,
      promptType: prompt != nil ? promptType : .free,
      promptText: prompt ?? ""
    )
    modelContext.insert(entry)
  }
}
