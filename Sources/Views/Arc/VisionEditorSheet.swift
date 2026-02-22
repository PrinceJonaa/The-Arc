import SwiftData
import SwiftUI

/// Sheet to write or edit the 5-year vision and 10-year calling.
struct VisionEditorSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @Query private var profiles: [UserProfile]

  @State private var fiveYear = ""
  @State private var tenYear = ""

  private var profile: UserProfile? { profiles.first }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          Text(
            "Your vision is your compass. Write what pulls you forward — not what sounds impressive."
          )
          .font(.subheadline)
          .foregroundStyle(.secondary)
        }

        Section {
          TextEditor(text: $fiveYear)
            .frame(minHeight: 100)
        } header: {
          Text("5-Year Vision")
        } footer: {
          Text("Where do you see yourself in 5 years?")
        }

        Section {
          TextEditor(text: $tenYear)
            .frame(minHeight: 100)
        } header: {
          Text("10-Year Calling")
        } footer: {
          Text("What you'd still do if nothing external validated it.")
        }
      }
      .navigationTitle("Your Vision")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            save()
            dismiss()
          }
          .fontWeight(.semibold)
        }
      }
      .onAppear {
        if let profile {
          fiveYear = profile.fiveYearVision
          tenYear = profile.tenYearCalling
        }
      }
    }
  }

  private func save() {
    if let profile {
      profile.fiveYearVision = fiveYear.trimmingCharacters(in: .whitespacesAndNewlines)
      profile.tenYearCalling = tenYear.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      let newProfile = UserProfile()
      newProfile.fiveYearVision = fiveYear.trimmingCharacters(in: .whitespacesAndNewlines)
      newProfile.tenYearCalling = tenYear.trimmingCharacters(in: .whitespacesAndNewlines)
      modelContext.insert(newProfile)
    }
  }
}
