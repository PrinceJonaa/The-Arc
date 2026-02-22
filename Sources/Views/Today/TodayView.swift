import SwiftData
import SwiftUI

struct TodayView: View {
  @Query(
    filter: #Predicate<Habit> { !$0.isArchived },
    sort: \Habit.createdAt
  )
  private var habits: [Habit]

  @Query(sort: \JournalEntry.date, order: .reverse)
  private var journalEntries: [JournalEntry]

  @State private var showComposeJournal = false

  private var greeting: String {
    let hour = Calendar.current.component(.hour, from: .now)
    switch hour {
    case 5..<12: return "Good Morning"
    case 12..<17: return "Good Afternoon"
    case 17..<21: return "Good Evening"
    default: return "Good Night"
    }
  }

  private var todayEntry: JournalEntry? {
    let calendar = Calendar.current
    return journalEntries.first { calendar.isDateInToday($0.date) }
  }

  private var thisWeekEntryCount: Int {
    let calendar = Calendar.current
    let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
    return journalEntries.filter { $0.date >= weekAgo }.count
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          // Greeting
          greetingHeader

          // FounderSelf: Daily Flame Check-In
          FlameCheckInCard()

          // FounderSelf: Daily Intention + Reflection Prompt
          DailyIntentionCard()

          // Existing: Habit progress
          HabitProgressCard(habits: habits)

          // Existing: Journal prompt
          JournalPromptCard(
            todayEntry: todayEntry,
            onCompose: { showComposeJournal = true }
          )

          // Existing: Weekly stats
          StatsCard(
            habits: habits,
            journalEntryCount: thisWeekEntryCount
          )
        }
        .padding()
      }
      .navigationTitle("Today")
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showComposeJournal) {
        ComposeJournalSheet(existingEntry: todayEntry)
      }
    }
  }

  private var greetingHeader: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(greeting)
          .font(.largeTitle.weight(.bold))
          .foregroundStyle(.primary)

        Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
    .padding(.bottom, 4)
  }
}

#Preview {
  TodayView()
    .modelContainer(
      for: [Habit.self, DailyLog.self, JournalEntry.self, FlameCheckIn.self],
      inMemory: true
    )
}
