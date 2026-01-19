// MARK: - Card View with Animations
import SwiftUI

// MARK: - Card Size Variants

// MARK: - Drag Modifier for Card Interaction

// MARK: - Preview
struct CardView: View {
  let card: Card
  var isFaceUp: Bool
  var isSelected: Bool = false
  var size: CardSize = .standard

  @Namespace private var cardAnimation

  var body: some View {
    ZStack {
      if isFaceUp {
        cardFrontView
      } else {
        cardBackView
      }
    }
    .frame(width: size.width, height: size.height)
    .rotation3DEffect(
      .degrees(isFaceUp ? 0 : 180),
      axis: (x: 0, y: 1, z: 0)
    )
    // Selected state float & glow
    .offset(y: isSelected ? -20 : 0)
    .scaleEffect(isSelected ? 1.05 : 1.0)
    .shadow(
      color: isSelected ? Color.neonPurple.opacity(0.5) : .black.opacity(0.2),
      radius: isSelected ? 15 : 5,
      y: isSelected ? 8 : 4
    )
    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    .animation(.easeInOut(duration: 0.4), value: isFaceUp)
  }

  // MARK: - Card Front
  private var cardFrontView: some View {
    ZStack {
      // Glass Base
      RoundedRectangle(cornerRadius: 12)
        .fill(.ultraThinMaterial)

      // Subtle White Tint
      RoundedRectangle(cornerRadius: 12)
        .fill(.white.opacity(0.1))

      // Glowing Border
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(
          LinearGradient(
            colors: [.white.opacity(0.5), .white.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 1.5
        )

      // Card Content
      VStack(spacing: 0) {
        // Top Corner
        HStack {
          VStack(spacing: -2) {
            Text(card.rank.rawValue)
              .font(.system(size: size == .small ? 14 : 20, weight: .bold, design: .rounded))
            Text(card.suit.rawValue)
              .font(.system(size: size == .small ? 14 : 18))
          }
          .foregroundStyle(suitColor)
          Spacer()
        }
        .padding(size == .small ? 4 : 8)

        Spacer()

        // Center Suit (Glowing)
        Text(card.suit.rawValue)
          .font(.system(size: size == .small ? 32 : 54))
          .foregroundStyle(suitColor.opacity(0.8))
          .shadow(color: suitColor.opacity(0.5), radius: 10)

        Spacer()

        // Bottom Corner (Rotated)
        HStack {
          Spacer()
          VStack(spacing: -2) {
            Text(card.suit.rawValue)
              .font(.system(size: size == .small ? 14 : 18))
            Text(card.rank.rawValue)
              .font(.system(size: size == .small ? 14 : 20, weight: .bold, design: .rounded))
          }
          .foregroundStyle(suitColor)
          .rotationEffect(.degrees(180))
        }
        .padding(size == .small ? 4 : 8)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  // MARK: - Card Back
  private var cardBackView: some View {
    ZStack {
      // Glass Base
      RoundedRectangle(cornerRadius: 12)
        .fill(.ultraThinMaterial)

      // Neon Gradient Back
      RoundedRectangle(cornerRadius: 12)
        .fill(
          LinearGradient(
            colors: [
              Color.neonPurple.opacity(0.2),
              Color.deepNavy.opacity(0.8),
              Color.neonTeal.opacity(0.2),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )

      // Geometric Pattern
      GeometryReader { geo in
        Path { path in
          let width = geo.size.width
          let height = geo.size.height

          // Simple modern lines
          path.move(to: CGPoint(x: 0, y: height * 0.2))
          path.addLine(to: CGPoint(x: width, y: height * 0.8))

          path.move(to: CGPoint(x: width * 0.2, y: 0))
          path.addLine(to: CGPoint(x: width * 0.8, y: height))
        }
        .stroke(Color.white.opacity(0.1), lineWidth: 1)
      }
      .clipShape(RoundedRectangle(cornerRadius: 12))

      // Border
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(
          LinearGradient(
            colors: [.white.opacity(0.3), .white.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 1
        )

      // Logo Icon Center
      Image(systemName: "suit.spade.fill")
        .font(.system(size: size == .small ? 20 : 30))
        .foregroundStyle(.white.opacity(0.3))
    }
    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))  // Counter-rotate content so it looks correct from "back"
  }

  // MARK: - Helpers
  private var suitColor: Color {
    switch card.suit {
    case .hearts, .diamonds: return .neonPink
    case .clubs, .spades: return .neonTeal
    case .joker: return .yellow
    }
  }
}
enum CardSize {
  case small
  case standard
  case large

  var width: CGFloat {
    switch self {
    case .small: return 50
    case .standard: return 70
    case .large: return 110
    }
  }

  var height: CGFloat {
    width * 1.5  // Slightly taller modern ratio
  }
}
struct CardDragModifier: ViewModifier {
  @State private var dragOffset: CGSize = .zero
  @State private var isDragging: Bool = false

  var onPlayCard: () -> Void

  func body(content: Content) -> some View {
    content
      .offset(dragOffset)
      .scaleEffect(isDragging ? 1.05 : 1.0)
      .gesture(
        DragGesture()
          .onChanged { value in
            isDragging = true
            dragOffset = value.translation
          }
          .onEnded { value in
            isDragging = false

            // If dragged up significantly (negative Y), play the card
            if value.translation.height < -100 {
              HapticsManager.shared.playCardPlayHaptic()
              onPlayCard()
            }

            // Reset position with animation
            withAnimation(.spring(response: 0.3)) {
              dragOffset = .zero
            }
          }
      )
  }
}
extension View {
  func cardDrag(onPlay: @escaping () -> Void) -> some View {
    modifier(CardDragModifier(onPlayCard: onPlay))
  }
}
#Preview("Glass Card") {
  ZStack {
    // Dark background to test glass effect
    Color.deepNavy.ignoresSafeArea()
    Circle().fill(Color.neonPurple).blur(radius: 50).frame(width: 100).offset(x: -50, y: -50)

    HStack(spacing: 20) {
      CardView(card: Card(suit: .hearts, rank: .ace), isFaceUp: true)
      CardView(card: Card(suit: .spades, rank: .king), isFaceUp: true, isSelected: true)
      CardView(card: Card(suit: .diamonds, rank: .seven), isFaceUp: false)
    }
  }
}
