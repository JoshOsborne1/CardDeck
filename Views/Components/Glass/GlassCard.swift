import SwiftUI

struct GlassCard<Content: View>: View {
  var cornerRadius: CGFloat = 20
  var padding: CGFloat = 16
  let content: Content

  init(cornerRadius: CGFloat = 20, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
    self.cornerRadius = cornerRadius
    self.padding = padding
    self.content = content()
  }

  var body: some View {
    content
      .padding(padding)
      .background(.ultraThinMaterial)
      .cornerRadius(cornerRadius)
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(
            LinearGradient(
              colors: [.white.opacity(0.3), .white.opacity(0.1)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ), lineWidth: 1)
      )
      .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
  }
}
#Preview {
  ZStack {
    Color.deepNavy.ignoresSafeArea()
    GlassCard {
      Text("Glass Card")
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(.white)
    }
  }
}
