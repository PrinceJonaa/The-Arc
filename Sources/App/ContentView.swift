import SwiftUI

struct ContentView: View {
  @State private var selectedTab = 0

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Today", systemImage: "sun.max.fill", value: 0) {
        TodayView()
      }

      Tab("Habits", systemImage: "checkmark.circle.fill", value: 1) {
        HabitsView()
      }

      Tab("Journal", systemImage: "book.fill", value: 2) {
        JournalView()
      }

      Tab("Settings", systemImage: "gearshape.fill", value: 3) {
        SettingsView()
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: [Habit.self, DailyLog.self, JournalEntry.self], inMemory: true)
}
