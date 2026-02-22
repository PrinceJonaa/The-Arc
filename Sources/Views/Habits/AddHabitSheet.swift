import SwiftData
import SwiftUI

struct AddHabitSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  var existingHabit: Habit?

  @State private var name = ""
  @State private var emoji = "⭐"
  @State private var frequency: HabitFrequency = .daily
  @State private var selectedColor = Color.blue

  private var isEditing: Bool { existingHabit != nil }

  private let emojiOptions = [
    "⭐", "💪", "📚", "🏃", "💧", "🧘", "🎯", "🌱", "✍️", "💤", "🍎", "🎨", "🎵", "🧹", "💊", "🐕",
  ]

  var body: some View {
    NavigationStack {
      Form {
        Section("Name") {
          TextField("e.g. Read 30 minutes", text: $name)
        }

        Section("Icon") {
          LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 8),
            spacing: 12
          ) {
            ForEach(emojiOptions, id: \.self) { option in
              Button {
                emoji = option
              } label: {
                Text(option)
                  .font(.title2)
                  .frame(width: 40, height: 40)
                  .background {
                    if emoji == option {
                      RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.tint.opacity(0.2))
                    }
                  }
              }
              .buttonStyle(.plain)
            }
          }
        }

        Section("Frequency") {
          Picker("Frequency", selection: $frequency) {
            ForEach(HabitFrequency.allCases) { freq in
              Text(freq.label).tag(freq)
            }
          }
          .pickerStyle(.segmented)
        }

        Section("Color") {
          ColorPicker("Accent Color", selection: $selectedColor, supportsOpacity: false)
        }
      }
      .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(isEditing ? "Save" : "Add") {
            save()
            dismiss()
          }
          .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
          .fontWeight(.semibold)
        }
      }
      .onAppear {
        if let habit = existingHabit {
          name = habit.name
          emoji = habit.emoji
          frequency = habit.frequency
          selectedColor = Color(hex: habit.colorHex) ?? .blue
        }
      }
    }
  }

  private func save() {
    let colorHex = selectedColor.hexString

    if let habit = existingHabit {
      habit.name = name.trimmingCharacters(in: .whitespaces)
      habit.emoji = emoji
      habit.frequency = frequency
      habit.colorHex = colorHex
    } else {
      let habit = Habit(
        name: name.trimmingCharacters(in: .whitespaces),
        emoji: emoji,
        colorHex: colorHex,
        frequency: frequency
      )
      modelContext.insert(habit)
    }
  }
}

// MARK: - Color ↔ Hex

extension Color {
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    guard hexSanitized.count == 6,
      let intValue = UInt64(hexSanitized, radix: 16)
    else {
      return nil
    }

    let red = Double((intValue >> 16) & 0xFF) / 255.0
    let green = Double((intValue >> 8) & 0xFF) / 255.0
    let blue = Double(intValue & 0xFF) / 255.0

    self.init(red: red, green: green, blue: blue)
  }

  var hexString: String {
    guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
      return "#007AFF"
    }
    let red = Int(components[0] * 255)
    let green = Int(components[1] * 255)
    let blue = Int(components[2] * 255)
    return String(format: "#%02X%02X%02X", red, green, blue)
  }
}

#Preview {
  AddHabitSheet()
    .modelContainer(for: Habit.self, inMemory: true)
}
