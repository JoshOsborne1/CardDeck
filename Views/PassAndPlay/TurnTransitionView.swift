import SwiftUI

// MARK: - Turn Transition View
struct TurnTransitionView: View {
    let coordinator: PassAndPlayCoordinator
    @State private var isAuthenticated = false
    @State private var showHand = false
    
    var body: some View {
        ZStack {
            // Background blur (privacy shield)
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Current player indicator
                VStack(spacing: 16) {
                    Text("PASS TO")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .tracking(2)
                    
                    // Player icon
                    Image(systemName: coordinator.currentPlayer.avatar)
                        .font(.system(size: 80))
                        .foregroundStyle(coordinator.currentPlayer.color.swiftUIColor)
                        .symbolEffect(.bounce, value: coordinator.currentPlayerIndex)
                    
                    // Player name
                    Text(coordinator.currentPlayer.name.uppercased())
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // Card count badge
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.on.rectangle")
                            .font(.system(size: 14))
                        Text("\(coordinator.currentPlayer.handCount) cards")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.1), in: Capsule())
                }
                
                Spacer()
                
                // Authentication button
                Button {
                    authenticateAndShowHand()
                } label: {
                    HStack(spacing: 12) {
                        if coordinator.requireFaceID {
                            Image(systemName: "faceid")
                                .font(.system(size: 24))
                        }
                        Text(coordinator.requireFaceID ? "I'M \(coordinator.currentPlayer.name.uppercased())" : "TAP TO VIEW CARDS")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(coordinator.currentPlayer.color.swiftUIColor, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: coordinator.currentPlayer.color.swiftUIColor.opacity(0.5), radius: 20)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .fullScreenCover(isPresented: $showHand) {
            PlayerHandView(coordinator: coordinator)
        }
    }
    
    private func authenticateAndShowHand() {
        coordinator.authenticatePlayer { success in
            if success {
                isAuthenticated = true
                // Slight delay for feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showHand = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let players = [
        Player(name: "Alex", avatar: "star.circle.fill", color: .blue),
        Player(name: "Jordan", avatar: "heart.circle.fill", color: .red),
        Player(name: "Sam", avatar: "bolt.circle.fill", color: .yellow)
    ]
    
    // Deal some cards for preview
    let deck = Deck.standard()
    deck.shuffle()
    players.forEach { player in
        player.addCards(deck.draw(count: 5))
    }
    
    let coordinator = PassAndPlayCoordinator(players: players, deck: deck)
    coordinator.gameInProgress = true
    
    return TurnTransitionView(coordinator: coordinator)
}
