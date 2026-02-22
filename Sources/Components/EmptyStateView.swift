import SwiftUI

/// Reusable empty-state placeholder with icon, title, subtitle, and optional CTA.
struct EmptyStateView: View {
  let systemImage: String
  let title: String
  let subtitle: String
  let actionTitle: String?
  let action: (() -> Void)?

  init(
    systemImage: String,
    title: String,
    subtitle: String,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.systemImage = systemImage
    self.title = title
    self.subtitle = subtitle
    self.actionTitle = actionTitle
    self.action = action
  }

  var body: some View {
    ContentUnavailableView {
      Label(title, systemImage: systemImage)
    } description: {
      Text(subtitle)
    } actions: {
      if let actionTitle, let action {
        Button(actionTitle, action: action)
          .buttonStyle(.borderedProminent)
          .controlSize(.regular)
      }
    }
  }
}

#Preview {
  EmptyStateView(
    systemImage: "checkmark.circle",
    title: "No Habits Yet",
    subtitle: "Start building better routines by adding your first habit.",
    actionTitle: "Add Habit"
  ) {
    // action
  }
}
