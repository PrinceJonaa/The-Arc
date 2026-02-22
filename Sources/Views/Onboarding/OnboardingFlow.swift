import SwiftData
import SwiftUI

/// 3-screen onboarding: Welcome → Devotion Anchor → Personality Tone.
struct OnboardingFlow: View {
  @Environment(\.modelContext) private var modelContext
  @State private var currentPage = 0
  @State private var devotionStatement = ""
  @State private var selectedTone: PersonalityTone = .builder

  let onComplete: () -> Void

  var body: some View {
    TabView(selection: $currentPage) {
      welcomePage.tag(0)
      devotionPage.tag(1)
      tonePage.tag(2)
    }
    .tabViewStyle(.page(indexDisplayMode: .always))
    .indexViewStyle(.page(backgroundDisplayMode: .always))
  }

  // MARK: - Welcome

  private var welcomePage: some View {
    VStack(spacing: 32) {
      Spacer()

      VStack(spacing: 16) {
        Text("🔥")
          .font(.system(size: 72))

        Text("The Arc")
          .font(.largeTitle.weight(.bold))
          .foregroundStyle(.primary)

        Text(
          "A daily companion that helps you remember\n"
            + "who you are, track where you're going, and\n"
            + "navigate the noise that gets in the way."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      }

      Spacer()

      VStack(spacing: 8) {
        Text(
          "Growth moves like the stock market —\nup and down, but always elevating for the great ones."
        )
        .font(.caption)
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)

        Button {
          withAnimation { currentPage = 1 }
        } label: {
          Text("Begin Your Arc")
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 32)
      }

      Spacer().frame(height: 40)
    }
  }

  // MARK: - Devotion Anchor

  private var devotionPage: some View {
    VStack(spacing: 24) {
      Spacer()

      VStack(spacing: 16) {
        Text("🪞")
          .font(.system(size: 56))

        Text("Your Devotion Anchor")
          .font(.title2.weight(.bold))
          .foregroundStyle(.primary)

        Text(
          "What is the thing that, even when everything\naround you is chaos, still feels like\nit belongs to you?"
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .italic()
        .padding(.horizontal)
      }

      TextEditor(text: $devotionStatement)
        .frame(height: 120)
        .padding(12)
        .background {
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.gray.opacity(0.1))
        }
        .padding(.horizontal, 24)

      Spacer()

      Button {
        withAnimation { currentPage = 2 }
      } label: {
        Text("Continue")
          .font(.headline.weight(.semibold))
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding(.horizontal, 32)
      .disabled(devotionStatement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

      Spacer().frame(height: 40)
    }
  }

  // MARK: - Personality Tone

  private var tonePage: some View {
    VStack(spacing: 24) {
      Spacer()

      VStack(spacing: 16) {
        Text("🎭")
          .font(.system(size: 56))

        Text("How Should I Speak to You?")
          .font(.title2.weight(.bold))
          .foregroundStyle(.primary)

        Text(
          "Pick the voice that feels most like yours.\nThis shapes your prompts and reflections."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
      }

      VStack(spacing: 8) {
        ForEach(PersonalityTone.allCases) { tone in
          toneRow(tone: tone)
        }
      }
      .padding(.horizontal, 24)

      Spacer()

      Button {
        completeOnboarding()
      } label: {
        Text("Start Your Journey")
          .font(.headline.weight(.semibold))
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding(.horizontal, 32)

      Spacer().frame(height: 40)
    }
  }

  private func toneRow(tone: PersonalityTone) -> some View {
    let isSelected = selectedTone == tone
    return Button {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        selectedTone = tone
      }
    } label: {
      HStack(spacing: 12) {
        Text(tone.emoji)
          .font(.title3)

        VStack(alignment: .leading, spacing: 2) {
          Text(tone.label)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
          Text(tone.description)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }

        Spacer()

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.blue)
        }
      }
      .padding(12)
      .background {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
          .overlay {
            if isSelected {
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            }
          }
      }
    }
    .buttonStyle(.plain)
  }

  private func completeOnboarding() {
    // Create user profile
    let profile = UserProfile(personalityTone: selectedTone)
    profile.onboardingCompletedAt = .now
    modelContext.insert(profile)

    // Create devotion anchor
    let trimmed = devotionStatement.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty {
      let anchor = DevotionAnchor(statement: trimmed)
      modelContext.insert(anchor)
    }

    onComplete()
  }
}
