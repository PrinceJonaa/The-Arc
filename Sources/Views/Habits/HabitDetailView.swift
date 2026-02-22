import SwiftData
import SwiftUI

struct HabitDetailView: View {
  @Bindable var habit: Habit
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @State private var showEditSheet = false
  @State private var showArchiveConfirm = false

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        headerCard
        statsCard
        calendarCard
        archiveButton
      }
      .padding()
    }
    .navigationTitle(habit.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          showEditSheet = true
        } label: {
          Label("Edit", systemImage: "pencil")
        }
      }
    }
    .sheet(isPresented: $showEditSheet) {
      AddHabitSheet(existingHabit: habit)
    }
    .confirmationDialog(
      "Archive Habit",
      isPresented: $showArchiveConfirm,
      titleVisibility: .visible
    ) {
      Button("Archive", role: .destructive) {
        habit.isArchived = true
        dismiss()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This habit will be hidden from your active list. Your history will be preserved.")
    }
  }
}

// MARK: - Subviews

extension HabitDetailView {
  private var headerCard: some View {
    GlassCard {
      HStack(spacing: 16) {
        Text(habit.emoji)
          .font(.system(size: 48))

        VStack(alignment: .leading, spacing: 4) {
          Text(habit.name)
            .font(.title2.weight(.bold))
            .foregroundStyle(.primary)

          Text(habit.frequency.label)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Spacer()

        StreakBadge(count: habit.currentStreak)
      }
    }
  }

  private var statsCard: some View {
    let streakCount = habit.currentStreak
    let weekRate = Int(habit.completionRate(days: 7) * 100)
    let monthRate = Int(habit.completionRate(days: 30) * 100)

    return GlassCard {
      HStack(spacing: 0) {
        DetailStatItem(value: "\(streakCount)", label: "Streak")
        Divider().frame(height: 40)
        DetailStatItem(value: "\(weekRate)%", label: "7-Day Rate")
        Divider().frame(height: 40)
        DetailStatItem(value: "\(monthRate)%", label: "30-Day Rate")
      }
    }
  }

  private var calendarCard: some View {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let days: [Date] = (0..<28).compactMap { offset in
      calendar.date(byAdding: .day, value: -offset, to: today)
    }.reversed()

    return GlassCard {
      VStack(alignment: .leading, spacing: 12) {
        Text("Last 4 Weeks")
          .font(.headline.weight(.semibold))
          .foregroundStyle(.primary)

        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
          spacing: 6
        ) {
          ForEach(days, id: \.self) { date in
            CalendarCell(
              date: date,
              isCompleted: habit.isCompleted(on: date),
              isToday: calendar.isDateInToday(date)
            )
          }
        }
      }
    }
  }

  private var archiveButton: some View {
    Button(role: .destructive) {
      showArchiveConfirm = true
    } label: {
      Label("Archive Habit", systemImage: "archivebox")
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bordered)
    .controlSize(.large)
  }
}

// MARK: - Supporting Views

private struct DetailStatItem: View {
  let value: String
  let label: String

  var body: some View {
    VStack(spacing: 4) {
      Text(value)
        .font(.title.weight(.bold))
        .foregroundStyle(.primary)
      Text(label)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }
}

private struct CalendarCell: View {
  let date: Date
  let isCompleted: Bool
  let isToday: Bool

  var body: some View {
    RoundedRectangle(cornerRadius: 4, style: .continuous)
      .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
      .aspectRatio(1, contentMode: .fit)
      .overlay {
        if isToday {
          RoundedRectangle(cornerRadius: 4, style: .continuous)
            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
        }
      }
      .accessibilityLabel(
        "\(date.formatted(.dateTime.month().day())): \(isCompleted ? "completed" : "not completed")"
      )
  }
}
