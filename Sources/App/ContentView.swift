import SwiftUI

struct ContentView: View {
  @State private var selectedTab = 0

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Home", systemImage: "house.fill", value: 0) {
        HomeView()
      }

      Tab("Settings", systemImage: "gearshape.fill", value: 1) {
        SettingsView()
      }
    }
  }
}

#Preview {
  ContentView()
}
