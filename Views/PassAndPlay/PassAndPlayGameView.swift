import SwiftUI

// MARK: - Pass & Play Game View (Main Game Container)
struct PassAndPlayGameView: View {
    let players: [Player]
    let deck: Deck
    let cardsPerPlayer: Int
    let freedomMode: Bool
    let requireAuth: Bool
    
    @Environment(\.dismiss) var dismiss
    @State private var coordinator: PassAndPlayCoordinator?
    @State private var showTransition = false
    @State private var showExitConfirmation = false
    
    var body: some View {
        ZStack {
            if let coordinator = coordinator {
                if showTransition {
                    TurnTransitionView(coordinator: coordinator)
                } else {
                    // Game in progress view (table view)
                    gameTableView(coordinator: coordinator)
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
        }
        .onAppear {
            setupGame()
        }
        .confirmationDialog("End Game", isPresented: $showExitConfirmation) {
            Button("End Game", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to end the current game?")
        }
    }
    
    private func gameTableView(coordinator: PassAndPlayCoordinator) -> some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "1a472a"), Color(hex: "0d2415")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Header with menu
                HStack {
                    Button {
                        showExitConfirmation = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Freedom mode indicator
                    if freedomMode {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.open.fill")
                            Text("FREEDOM MODE")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: "d4af37"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.1), in: Capsule())
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            coordinator.resetGame()
                            coordinator.dealCards(cardsPerPlayer: cardsPerPlayer)
                        } label: {
                            Label("New Deal", systemImage: "arrow.clockwise")
                        }
                        
                        Button(role: .destructive) {
                            showExitConfirmation = true
                        } label: {
                            Label("End Game", systemImage: "xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding()
                
                Spacer()
                
                // Table center (deck and discard pile)
                tableCenterView(coordinator: coordinator)
                
                Spacer()
                
                // Player indicators around the table
                playerIndicators(coordinator: coordinator)
                    .padding(.bottom, 40)
            }
        }
    }
    
    private func tableCenterView(coordinator: PassAndPlayCoordinator) -> some View {
        HStack(spacing: 40) {
            // Draw pile
            VStack(spacing: 12) {
                ZStack {
                    // Stack of cards
                    ForEach(0..<min(3, coordinator.deck.remainingCount), id: \.self) { index in
                        CardView(card: Card(suit: .spades, rank: .ace), isFaceUp: false, size: .standard)
                            .offset(x: CGFloat(index) * 2, y: CGFloat(index) * -2)
                    }
                }
                
                Text("\(coordinator.deck.remainingCount) cards")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("DRAW PILE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(1)
            }
            
            // Discard pile
            VStack(spacing: 12) {
                ZStack {
                    if let topCard = coordinator.deck.topDiscardCard {
                        CardView(card: topCard, isFaceUp: true, size: .standard)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.white.opacity(0.3), lineWidth: 2, antialiased: true)
                            .frame(width: 80, height: 112)
                    }
                }
                
                Text("\(coordinator.deck.discardCount) cards")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("DISCARD PILE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(1)
            }
        }
    }
    
    private func playerIndicators(coordinator: PassAndPlayCoordinator) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(coordinator.players.enumerated()), id: \.element.id) { index, player in
                    PlayerIndicator(
                        player: player,
                        isCurrentPlayer: index == coordinator.currentPlayerIndex
                    )
                    .onTapGesture {
                        if index == coordinator.currentPlayerIndex {
                            showTransition = true
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func setupGame() {
        let gameCoordinator = PassAndPlayCoordinator(players: players, deck: deck)
        gameCoordinator.requireFaceID = requireAuth
        gameCoordinator.freedomMode = freedomMode
        
        // Deal cards
        deck.shuffle()
        gameCoordinator.dealCards(cardsPerPlayer: cardsPerPlayer)
        
        coordinator = gameCoordinator
    }
}

// MARK: - Player Indicator
struct PlayerIndicator: View {
    let player: Player
    let isCurrentPlayer: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: player.avatar)
                .font(.system(size: 32))
                .foregroundStyle(player.color.swiftUIColor)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(player.color.swiftUIColor.opacity(0.2))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isCurrentPlayer ? player.color.swiftUIColor : .clear,
                                    lineWidth: 3
                                )
                        )
                )
            
            Text(player.name)
                .font(.system(size: 13, weight: isCurrentPlayer ? .bold : .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            
            Text("\(player.handCount) 🃏")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentPlayer ? .white.opacity(0.15) : .white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isCurrentPlayer ? Color(hex: "d4af37") : .clear,
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Preview
#Preview {
    let players = [
        Player(name: "Alex", avatar: "star.circle.fill", color: .blue),
        Player(name: "Jordan", avatar: "heart.circle.fill", color: .red),
        Player(name: "Sam", avatar: "bolt.circle.fill", color: .yellow)
    ]
    
    return PassAndPlayGameView(
        players: players,
        deck: Deck.standard(),
        cardsPerPlayer: 7,
        freedomMode: true,
        requireAuth: false
    )
}
