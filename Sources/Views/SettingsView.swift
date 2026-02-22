import SwiftUI

struct SettingsView: View {
  var body: some View {
    NavigationStack {
      List {
        Section("General") {
          Label("Appearance", systemImage: "paintbrush.fill")
          Label("Notifications", systemImage: "bell.fill")
        }

        Section("About") {
          Label("Version", systemImage: "info.circle.fill")
        }
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview {
  SettingsView()
}
