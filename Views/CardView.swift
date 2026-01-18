import SwiftUI

// MARK: - Card View with Animations
struct CardView: View {
    let card: Card
    var isFaceUp: Bool
    var isSelected: Bool = false
    var size: CardSize = .standard
    
    @Namespace private var cardAnimation
    
    var body: some View {
        ZStack {
            if isFaceUp {
                // Front of card
                cardFrontView
            } else {
                // Back of card
                cardBackView
            }
        }
        .frame(width: size.width, height: size.height)
        .rotation3DEffect(
            .degrees(isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .shadow(color: .black.opacity(0.3), radius: isSelected ? 10 : 5, y: isSelected ? 8 : 4)
        .offset(y: isSelected ? -20 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.4), value: isFaceUp)
    }
    
    // MARK: - Card Front
    private var cardFrontView: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
            
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(card.suit.color.opacity(0.3), lineWidth: 2)
            
            // Card content
            VStack(spacing: 8) {
                // Top-left corner
                HStack {
                    VStack(spacing: 0) {
                        Text(card.rank.rawValue)
                            .font(.system(size: size == .small ? 18 : 24, weight: .bold))
                        Text(card.suit.rawValue)
                            .font(.system(size: size == .small ? 16 : 20))
                    }
                    .foregroundStyle(card.suit.color)
                    Spacer()
                }
                .padding(8)
                
                Spacer()
                
                // Center suit symbol (large)
                Text(card.suit.rawValue)
                    .font(.system(size: size == .small ? 40 : 60))
                    .foregroundStyle(card.suit.color.opacity(0.2))
                
                Spacer()
                
                // Bottom-right corner (rotated)
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text(card.suit.rawValue)
                            .font(.system(size: size == .small ? 16 : 20))
                        Text(card.rank.rawValue)
                            .font(.system(size: size == .small ? 18 : 24, weight: .bold))
                    }
                    .foregroundStyle(card.suit.color)
                    .rotationEffect(.degrees(180))
                }
                .padding(8)
            }
        }
    }
    
    // MARK: - Card Back
    private var cardBackView: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1a3a52"), Color(hex: "0d1d29")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Pattern
            VStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    HStack(spacing: 4) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.1))
                                .frame(width: 12, height: 16)
                        }
                    }
                }
            }
            
            // Border
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.2), lineWidth: 2)
        }
    }
}

// MARK: - Card Size Variants
enum CardSize {
    case small
    case standard
    case large
    
    var width: CGFloat {
        switch self {
        case .small: return 60
        case .standard: return 80
        case .large: return 120
        }
    }
    
    var height: CGFloat {
        width * 1.4 // Standard playing card ratio (2.5" × 3.5")
    }
}

// MARK: - Drag Modifier for Card Interaction
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
                        
                        // If dragged up significantly, play the card
                        if value.translation.height < -100 {
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

// MARK: - Preview
#Preview("Single Card") {
    VStack(spacing: 40) {
        CardView(card: Card(suit: .hearts, rank: .ace), isFaceUp: true)
        CardView(card: Card(suit: .spades, rank: .king), isFaceUp: false)
        CardView(card: Card(suit: .diamonds, rank: .seven), isFaceUp: true, isSelected: true)
    }
    .padding()
    .background(Color(hex: "1a472a"))
}

#Preview("Card Sizes") {
    HStack(spacing: 20) {
        CardView(card: Card(suit: .clubs, rank: .queen), isFaceUp: true, size: .small)
        CardView(card: Card(suit: .hearts, rank: .queen), isFaceUp: true, size: .standard)
        CardView(card: Card(suit: .diamonds, rank: .queen), isFaceUp: true, size: .large)
    }
    .padding()
    .background(Color(hex: "1a472a"))
}
