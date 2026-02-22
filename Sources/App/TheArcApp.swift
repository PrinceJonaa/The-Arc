import SwiftData
import SwiftUI

@main
struct TheArcApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(for: [
      Habit.self,
      DailyLog.self,
      JournalEntry.self,
    ])
  }
}
