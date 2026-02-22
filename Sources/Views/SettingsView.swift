import SwiftData
import SwiftUI

struct SettingsView: View {
  @AppStorage("appearance") private var appearance: String = "system"
  @AppStorage("hapticFeedback") private var hapticFeedback = true

  @Environment(\.modelContext) private var modelContext
  @StateObject private var notifications = NotificationManager()

  @Query private var profiles: [UserProfile]
  @Query(sort: \DevotionAnchor.createdAt, order: .reverse)
  private var anchors: [DevotionAnchor]

  @State private var showClearConfirm = false
  @State private var showEditAnchor = false
  @State private var editedAnchorText = ""
  @State private var showRecalibration = false

  private var profile: UserProfile? { profiles.first }
  private var anchor: DevotionAnchor? { anchors.first }

  var body: some View {
    NavigationStack {
      List {
        myArcSection
        visionSection
        notificationsSection
        appearanceSection
        feedbackSection
        dataSection
        aboutSection
      }
      .navigationTitle("Settings")
      .preferredColorScheme(colorScheme)
      .confirmationDialog(
        "Clear All Data",
        isPresented: $showClearConfirm,
        titleVisibility: .visible
      ) {
        Button("Clear Everything", role: .destructive) {
          clearAllData()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This will permanently delete all habits, logs, journal entries, and check-ins.")
      }
      .alert("Edit Devotion Anchor", isPresented: $showEditAnchor) {
        TextField("Your anchor", text: $editedAnchorText)
        Button("Save") {
          saveAnchor()
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("What is the thing that still feels like it belongs to you?")
      }
    }
  }

  // MARK: - Sections

  private var myArcSection: some View {
    Section("My Arc") {
      // Devotion Anchor
      if let anchor {
        Button {
          editedAnchorText = anchor.statement
          showEditAnchor = true
        } label: {
          HStack {
            Label("Devotion Anchor", systemImage: "flame.circle.fill")
            Spacer()
            Text(anchor.statement)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .frame(maxWidth: 150, alignment: .trailing)
          }
        }
      }

      // Current Phase
      if let profile {
        HStack {
          Label("Current Phase", systemImage: "map.fill")
          Spacer()
          Picker("Phase", selection: phaseBinding) {
            ForEach(ArcPhase.allCases) { phase in
              Text("\(phase.emoji) \(phase.label)").tag(phase)
            }
          }
          .pickerStyle(.menu)
        }
      }

      // Personality Tone
      if let profile {
        HStack {
          Label("Voice", systemImage: "waveform")
          Spacer()
          Picker("Tone", selection: toneBinding) {
            ForEach(PersonalityTone.allCases) { tone in
              Text("\(tone.emoji) \(tone.label)").tag(tone)
            }
          }
          .pickerStyle(.menu)
        }

        // Recalibrate
        Button {
          showRecalibration = true
        } label: {
          HStack {
            Label("Recalibrate Voice", systemImage: "waveform.path.ecg")
            Spacer()
            if profile.needsRecalibration {
              Text("Due")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.purple)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background {
                  Capsule(style: .continuous)
                    .fill(Color.purple.opacity(0.12))
                }
            }
          }
        }
      }
    }
    .sheet(isPresented: $showRecalibration) {
      RecalibrationView()
    }
  }

  private var visionSection: some View {
    Section("Vision") {
      NavigationLink {
        VisionEditorSheet()
      } label: {
        HStack {
          Label("5-Year & 10-Year Vision", systemImage: "scope")
          Spacer()
          if let profile, !profile.fiveYearVision.isEmpty {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(.green)
              .font(.caption)
          }
        }
      }
    }
  }

  private var notificationsSection: some View {
    Section("Reminders") {
      Toggle(isOn: $notifications.morningEnabled) {
        Label("Morning Flame", systemImage: "sunrise.fill")
      }

      if notifications.morningEnabled {
        DatePicker(
          "Time",
          selection: $notifications.morningTime,
          displayedComponents: .hourAndMinute
        )
      }

      Toggle(isOn: $notifications.eveningEnabled) {
        Label("Evening Reflection", systemImage: "moon.fill")
      }

      if notifications.eveningEnabled {
        DatePicker(
          "Time",
          selection: $notifications.eveningTime,
          displayedComponents: .hourAndMinute
        )
      }
    }
    .task {
      await notifications.requestPermission()
    }
  }

  private var appearanceSection: some View {
    Section("Appearance") {
      Picker("Theme", selection: $appearance) {
        Text("System").tag("system")
        Text("Light").tag("light")
        Text("Dark").tag("dark")
      }
    }
  }

  private var feedbackSection: some View {
    Section("Feedback") {
      Toggle("Haptic Feedback", isOn: $hapticFeedback)
    }
  }

  private var dataSection: some View {
    Section("Data") {
      Button(role: .destructive) {
        showClearConfirm = true
      } label: {
        Label("Clear All Data", systemImage: "trash")
      }
    }
  }

  private var aboutSection: some View {
    Section("About") {
      HStack {
        Text("Version")
        Spacer()
        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0")
          .foregroundStyle(.secondary)
      }
      HStack {
        Text("Build")
        Spacer()
        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
          .foregroundStyle(.secondary)
      }
    }
  }

  // MARK: - Helpers

  private var phaseBinding: Binding<ArcPhase> {
    Binding(
      get: { profile?.currentPhase ?? .ignition },
      set: { profile?.currentPhase = $0 }
    )
  }

  private var toneBinding: Binding<PersonalityTone> {
    Binding(
      get: { profile?.personalityTone ?? .builder },
      set: { profile?.personalityTone = $0 }
    )
  }

  private var colorScheme: ColorScheme? {
    switch appearance {
    case "light": .light
    case "dark": .dark
    default: nil
    }
  }

  private func saveAnchor() {
    let trimmed = editedAnchorText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }

    if let anchor {
      anchor.statement = trimmed
      anchor.lastRevisedAt = .now
    } else {
      let newAnchor = DevotionAnchor(statement: trimmed)
      modelContext.insert(newAnchor)
    }
  }

  private func clearAllData() {
    do {
      try modelContext.delete(model: DailyLog.self)
      try modelContext.delete(model: Habit.self)
      try modelContext.delete(model: JournalEntry.self)
      try modelContext.delete(model: FlameCheckIn.self)
      try modelContext.delete(model: DevotionAnchor.self)
      try modelContext.delete(model: UserProfile.self)
    } catch {
      // SwiftData maintains integrity
    }
  }
}

#Preview {
  SettingsView()
    .modelContainer(
      for: [
        Habit.self, DailyLog.self, JournalEntry.self,
        FlameCheckIn.self, UserProfile.self, DevotionAnchor.self,
      ],
      inMemory: true
    )
}
