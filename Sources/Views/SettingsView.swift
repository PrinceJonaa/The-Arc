import SwiftData
import SwiftUI

struct SettingsView: View {
  @AppStorage("appearance") private var appearance: String = "system"
  @AppStorage("hapticFeedback") private var hapticFeedback = true

  @Environment(\.modelContext) private var modelContext

  @State private var showClearConfirm = false

  var body: some View {
    NavigationStack {
      List {
        Section("Appearance") {
          Picker("Theme", selection: $appearance) {
            Text("System").tag("system")
            Text("Light").tag("light")
            Text("Dark").tag("dark")
          }
        }

        Section("Feedback") {
          Toggle("Haptic Feedback", isOn: $hapticFeedback)
        }

        Section("Data") {
          Button(role: .destructive) {
            showClearConfirm = true
          } label: {
            Label("Clear All Data", systemImage: "trash")
          }
        }

        Section("About") {
          HStack {
            Text("Version")
            Spacer()
            Text(
              Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
            )
            .foregroundStyle(.secondary)
          }

          HStack {
            Text("Build")
            Spacer()
            Text(
              Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            )
            .foregroundStyle(.secondary)
          }
        }
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
        Text("This will permanently delete all habits, logs, and journal entries.")
      }
    }
  }

  private var colorScheme: ColorScheme? {
    switch appearance {
    case "light": .light
    case "dark": .dark
    default: nil
    }
  }

  private func clearAllData() {
    do {
      try modelContext.delete(model: DailyLog.self)
      try modelContext.delete(model: Habit.self)
      try modelContext.delete(model: JournalEntry.self)
    } catch {
      // Silently fail — data integrity is maintained by SwiftData
    }
  }
}

#Preview {
  SettingsView()
    .modelContainer(for: [Habit.self, DailyLog.self, JournalEntry.self], inMemory: true)
}
