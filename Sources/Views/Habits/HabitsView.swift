import SwiftData
import SwiftUI

struct HabitsView: View {
  @Query(
    filter: #Predicate<Habit> { !$0.isArchived },
    sort: \Habit.createdAt
  )
  private var habits: [Habit]

  @State private var showAddHabit = false

  var body: some View {
    NavigationStack {
      Group {
        if habits.isEmpty {
          EmptyStateView(
            systemImage: "checkmark.circle",
            title: "No Habits Yet",
            subtitle: "Start building better routines by adding your first habit.",
            actionTitle: "Add Habit"
          ) {
            showAddHabit = true
          }
        } else {
          ScrollView {
            LazyVStack(spacing: 12) {
              ForEach(habits) { habit in
                NavigationLink(value: habit) {
                  HabitRow(habit: habit)
                }
                .buttonStyle(.plain)
              }
            }
            .padding()
          }
        }
      }
      .navigationTitle("Habits")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showAddHabit = true
          } label: {
            Label("Add Habit", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showAddHabit) {
        AddHabitSheet()
      }
      .navigationDestination(for: Habit.self) { habit in
        HabitDetailView(habit: habit)
      }
    }
  }
}

#Preview {
  HabitsView()
    .modelContainer(for: [Habit.self, DailyLog.self], inMemory: true)
}
