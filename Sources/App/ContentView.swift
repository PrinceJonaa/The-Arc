import SwiftData
import SwiftUI

struct ContentView: View {
  @Query private var profiles: [UserProfile]
  @State private var selectedTab = 0
  @State private var showOnboarding = false

  private var hasCompletedOnboarding: Bool {
    profiles.first?.hasCompletedOnboarding ?? false
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      Tab("Today", systemImage: "sun.max.fill", value: 0) {
        TodayView()
      }

      Tab("Arc", systemImage: "chart.line.uptrend.xyaxis", value: 1) {
        ArcView()
      }

      Tab("Habits", systemImage: "checkmark.circle.fill", value: 2) {
        HabitsView()
      }

      Tab("Journal", systemImage: "book.fill", value: 3) {
        JournalView()
      }

      Tab("Settings", systemImage: "gearshape.fill", value: 4) {
        SettingsView()
      }
    }
    .onAppear {
      if !hasCompletedOnboarding {
        showOnboarding = true
      }
    }
    .fullScreenCover(isPresented: $showOnboarding) {
      OnboardingFlow {
        showOnboarding = false
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(
      for: [
        Habit.self, DailyLog.self, JournalEntry.self,
        FlameCheckIn.self, UserProfile.self, DevotionAnchor.self,
      ],
      inMemory: true
    )
}
