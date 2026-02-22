import SwiftData
import SwiftUI

/// 30-day personality recalibration view.
/// Analyzes journal patterns, shows tone breakdown, and lets user confirm or shift.
struct RecalibrationView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @Query private var profiles: [UserProfile]
  @Query(sort: \JournalEntry.date, order: .reverse)
  private var entries: [JournalEntry]

  @State private var selectedTone: PersonalityTone?
  @State private var showConfirmation = false

  private var profile: UserProfile? { profiles.first }

  private var signals: [RecalibrationEngine.ToneSignal] {
    RecalibrationEngine.analyze(entries: entries)
  }

  private var suggestion: PersonalityTone? {
    guard let profile else { return nil }
    return RecalibrationEngine.suggestedTone(
      from: entries,
      currentTone: profile.personalityTone
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          headerSection
          currentToneCard
          signalBreakdown

          if let suggestion {
            suggestionCard(suggestion: suggestion)
          }

          toneSelector
          confirmButton
        }
        .padding()
      }
      .navigationTitle("Recalibrate")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Skip") {
            // Mark as calibrated even if skipped
            profile?.lastCalibratedAt = .now
            dismiss()
          }
        }
      }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "waveform.path.ecg")
        .font(.system(size: 40))
        .foregroundStyle(.purple)

      Text("30-Day Check-In")
        .font(.title2.weight(.bold))

      Text(
        "Your words over the last 30 days tell a story."
          + " Let's see if your voice has evolved."
      )
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
    }
    .padding(.top, 8)
  }

  // MARK: - Current Tone

  private var currentToneCard: some View {
    GlassCard {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Current Voice")
            .font(.caption)
            .foregroundStyle(.secondary)
          HStack(spacing: 6) {
            Text(profile?.personalityTone.emoji ?? "🎭")
              .font(.title2)
            Text(profile?.personalityTone.label ?? "Builder")
              .font(.headline.weight(.semibold))
          }
        }
        Spacer()
        Text("30 days")
          .font(.caption.weight(.medium))
          .foregroundStyle(.purple)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background {
            Capsule(style: .continuous)
              .fill(Color.purple.opacity(0.12))
          }
      }
    }
  }

  // MARK: - Signal Breakdown

  private var signalBreakdown: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("What Your Words Say")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.primary)

        if signals.isEmpty || entries.isEmpty {
          Text("Not enough journal entries to analyze yet.")
            .font(.caption)
            .foregroundStyle(.tertiary)
        } else {
          ForEach(signals) { signal in
            signalRow(signal: signal)
          }
        }
      }
    }
  }

  private func signalRow(signal: RecalibrationEngine.ToneSignal) -> some View {
    VStack(spacing: 4) {
      HStack {
        Text(signal.tone.emoji)
          .font(.caption)
        Text(signal.tone.label)
          .font(.caption.weight(.medium))
          .foregroundStyle(.primary)
        Spacer()
        Text("\(Int(signal.score * 100))%")
          .font(.caption.weight(.semibold).monospacedDigit())
          .foregroundStyle(
            signal.tone == profile?.personalityTone ? .purple : .secondary
          )
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule(style: .continuous)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 4)

          Capsule(style: .continuous)
            .fill(
              signal.tone == profile?.personalityTone
                ? Color.purple : Color.blue.opacity(0.6)
            )
            .frame(width: geo.size.width * signal.score, height: 4)
        }
      }
      .frame(height: 4)
    }
  }

  // MARK: - Suggestion

  private func suggestionCard(suggestion: PersonalityTone) -> some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "sparkles")
            .foregroundStyle(.purple)
          Text("Shift Detected")
            .font(.subheadline.weight(.semibold))
        }

        Text(
          "Your recent journal entries lean "
            + "\(suggestion.emoji) \(suggestion.label). "
            + "Your words suggest you might be evolving."
        )
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
  }

  // MARK: - Tone Selector

  private var toneSelector: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Your Voice Going Forward")
        .font(.subheadline.weight(.semibold))

      ForEach(PersonalityTone.allCases) { tone in
        toneOption(tone: tone)
      }
    }
  }

  private func toneOption(tone: PersonalityTone) -> some View {
    let isSelected = (selectedTone ?? profile?.personalityTone) == tone
    let isSuggested = tone == suggestion

    return Button {
      selectedTone = tone
    } label: {
      HStack(spacing: 12) {
        Text(tone.emoji)
          .font(.title3)

        VStack(alignment: .leading, spacing: 2) {
          HStack {
            Text(tone.label)
              .font(.subheadline.weight(.medium))
            if isSuggested {
              Text("suggested")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.purple)
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background {
                  Capsule(style: .continuous)
                    .fill(Color.purple.opacity(0.12))
                }
            }
          }
          Text(tone.description)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }

        Spacer()

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(isSelected ? Color.purple : Color.gray)
          .font(.title3)
      }
      .padding(12)
      .adaptiveGlass(cornerRadius: 12)
      .overlay {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(
            isSelected ? Color.purple.opacity(0.4) : .clear,
            lineWidth: 2
          )
      }
    }
    .buttonStyle(.plain)
  }

  // MARK: - Confirm

  private var confirmButton: some View {
    Button {
      let chosen = selectedTone ?? profile?.personalityTone ?? .builder
      profile?.personalityTone = chosen
      profile?.lastCalibratedAt = .now
      showConfirmation = true

      DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        dismiss()
      }
    } label: {
      Text("Confirm My Voice")
        .font(.headline.weight(.semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.purple)
        }
        .foregroundStyle(.white)
    }
    .overlay {
      if showConfirmation {
        Text("✅ Calibrated")
          .font(.headline)
          .transition(.scale.combined(with: .opacity))
      }
    }
    .padding(.top, 8)
  }
}

#Preview {
  RecalibrationView()
    .modelContainer(
      for: [UserProfile.self, JournalEntry.self],
      inMemory: true
    )
}
