// MARK: - Turn Transition View
import SwiftUI

// MARK: - Preview
struct TurnTransitionView: View {
  let coordinator: PassAndPlayCoordinator
  @State private var isAuthenticated = false
  @State private var showHand = false

  var body: some View {
    ZStack {
      // Background blur (privacy shield)
      GlassBackgroundView()

      // Additional darkening for privacy
      Color.black.opacity(0.4)
        .ignoresSafeArea()

      VStack(spacing: 40) {
        Spacer()

        // Current player indicator
        VStack(spacing: 16) {
          Text("PASS TO")
            .font(.system(size: 16, weight: .black))
            .foregroundStyle(.white.opacity(0.6))
            .tracking(2)

          // Player icon
          Image(systemName: coordinator.currentPlayer.avatar)
            .font(.system(size: 80))
            .foregroundStyle(coordinator.currentPlayer.color.swiftUIColor)
            .symbolEffect(.bounce, value: coordinator.currentPlayerIndex)
            .shadow(color: coordinator.currentPlayer.color.swiftUIColor.opacity(0.6), radius: 20)

          // Player name
          Text(coordinator.currentPlayer.name.uppercased())
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.3), radius: 4)

          // Card count badge
          GlassCard {
            HStack(spacing: 8) {
              Image(systemName: "rectangle.3.group.fill")
                .font(.system(size: 14))
              Text("\(coordinator.currentPlayer.handCount) cards")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
          }
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
            Text(
              coordinator.requireFaceID
                ? "I'M \(coordinator.currentPlayer.name.uppercased())" : "TAP TO VIEW CARDS"
            )
            .font(.system(size: 18, weight: .bold, design: .rounded))
          }
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 20)
          .background(
            coordinator.currentPlayer.color.swiftUIColor
              .shadow(.inner(color: .white.opacity(0.3), radius: 1, x: 0, y: 1))
              .shadow(
                .drop(color: coordinator.currentPlayer.color.swiftUIColor.opacity(0.5), radius: 10))
          )
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(.white.opacity(0.3), lineWidth: 1)
          )
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
        HapticsManager.shared.playImpactHaptic(style: .medium)
        // Slight delay for feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          showHand = true
        }
      }
    }
  }
}
#Preview {
  let players = [
    Player(name: "Alex", avatar: "star.circle.fill", color: .neonPurple),
    Player(name: "Jordan", avatar: "heart.circle.fill", color: .neonPink),
    Player(name: "Sam", avatar: "bolt.circle.fill", color: .neonTeal),
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
