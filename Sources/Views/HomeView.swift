import SwiftUI

struct HomeView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          GlassCard {
            VStack(alignment: .leading, spacing: 8) {
              Text("Welcome to The Arc")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

              Text("Your journey starts here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding()
      }
      .navigationTitle("Home")
    }
  }
}

#Preview {
  HomeView()
}
