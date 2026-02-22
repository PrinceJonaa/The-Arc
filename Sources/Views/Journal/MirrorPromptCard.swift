import SwiftData
import SwiftUI

/// Weekly mirror prompt card surfaced at the top of JournalView.
struct MirrorPromptCard: View {
  let onTapPrompt: (String) -> Void

  private var mirrorPrompt: String {
    ReflectionPrompts.weeklyMirror()
  }

  /// Only show once per week.
  @AppStorage("lastMirrorWeek") private var lastMirrorWeek: Int = 0

  private var currentWeek: Int {
    Calendar.current.component(.weekOfYear, from: .now)
  }

  var body: some View {
    if currentWeek != lastMirrorWeek {
      GlassCard {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Image(systemName: "person.crop.circle")
              .foregroundStyle(.purple)
            Text("Weekly Mirror")
              .font(.caption.weight(.semibold))
              .foregroundStyle(.purple)
            Spacer()
            Button {
              lastMirrorWeek = currentWeek
            } label: {
              Image(systemName: "xmark")
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
          }

          Text(mirrorPrompt)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .italic()

          Button {
            onTapPrompt(mirrorPrompt)
            lastMirrorWeek = currentWeek
          } label: {
            Text("Reflect on this")
              .font(.caption.weight(.semibold))
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .tint(.purple)
          .controlSize(.small)
        }
      }
    }
  }
}
