import SwiftUI

struct GlassBackgroundView: View {
  @State private var animateGradient = false

  var body: some View {
    ZStack {
      Color.deepNavy.ignoresSafeArea()

      // Animated background mesh (simplified for now)
      LinearGradient(
        colors: [Color.deepNavy, Color.neonPurple.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      // Circles
      Circle()
        .fill(Color.neonTeal.opacity(0.1))
        .blur(radius: 60)
        .frame(width: 200, height: 200)
        .offset(x: -100, y: -200)

      Circle()
        .fill(Color.neonPurple.opacity(0.1))
        .blur(radius: 60)
        .frame(width: 300, height: 300)
        .offset(x: 100, y: 300)
    }
  }
}
