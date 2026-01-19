import SwiftUI

struct GlassButton: View {
  let title: String
  var icon: String? = nil
  var color: Color = .neonPurple
  let action: () -> Void

  var body: some View {
    Button(action: {
      HapticsManager.shared.playImpactHaptic(style: .light)
      action()
    }) {
      HStack(spacing: 8) {
        Text(title)
          .font(.headline)
          .fontWeight(.bold)

        if let icon = icon {
          Image(systemName: icon)
            .font(.headline)
            .fontWeight(.bold)
        }
      }
      .foregroundStyle(.white)
      .padding(.vertical, 14)
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity)
      .background(
        ZStack {
          // Glass background
          Material.ultraThin

          // Subtle tint
          color.opacity(0.15)

          // Gradient border
          RoundedRectangle(cornerRadius: 16)
            .stroke(
              LinearGradient(
                colors: [color.opacity(0.8), color.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              lineWidth: 1
            )
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
  }
}
#Preview {
  ZStack {
    Color.deepNavy.ignoresSafeArea()
    VStack(spacing: 20) {
      GlassButton(title: "Play Now", icon: "play.fill") {}
      GlassButton(title: "Settings", icon: "gear", color: .neonTeal) {}
    }
    .padding()
  }
}
