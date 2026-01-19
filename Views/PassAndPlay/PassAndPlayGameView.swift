// MARK: - Pass & Play Game View (Main Game Container)
import SwiftUI

// MARK: - Player Indicator

// MARK: - Preview
struct PassAndPlayGameView: View {
  let players: [Player]
  let deck: Deck
  let cardsPerPlayer: Int
  let freedomMode: Bool
  let requireAuth: Bool

  @Environment(\.dismiss) var dismiss
  @Namespace private var gameNamespace  // For matchedGeometryEffect animations
  @State private var coordinator: PassAndPlayCoordinator?
  @State private var showTransition = false
  @State private var showExitConfirmation = false

  var body: some View {
    ZStack {
      GlassBackgroundView()

      if let coordinator = coordinator {
        if showTransition {
          TurnTransitionView(coordinator: coordinator)
            .transition(.opacity)
        } else {
          // Game in progress view (table view)
          gameTableView(coordinator: coordinator)
            .transition(.opacity)
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
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Are you sure you want to end the current game?")
    }
  }

  private func gameTableView(coordinator: PassAndPlayCoordinator) -> some View {
    VStack {
      // Header with menu
      HStack {
        Button {
          showExitConfirmation = true
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 28))
            .foregroundStyle(.white.opacity(0.6))
            .background(Circle().fill(.ultraThinMaterial))
        }

        Spacer()

        // Freedom mode indicator
        if freedomMode {
          HStack(spacing: 6) {
            Image(systemName: "lock.open.fill")
            Text("FREEDOM MODE")
          }
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(Color.neonPink)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(
            Capsule()
              .fill(.ultraThinMaterial)
              .stroke(Color.neonPink.opacity(0.3), lineWidth: 1)
          )
        }

        Spacer()

        Menu {
          Button {
            withAnimation {
              coordinator.resetGame()
              coordinator.dealCards(cardsPerPlayer: cardsPerPlayer)
            }
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
            .foregroundStyle(.white.opacity(0.6))
            .background(Circle().fill(.ultraThinMaterial))
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

  private func tableCenterView(coordinator: PassAndPlayCoordinator) -> some View {
    HStack(spacing: 40) {
      // Draw pile
      VStack(spacing: 12) {
        ZStack {
          // Stack of cards
          ForEach(0..<min(3, coordinator.deck.remainingCount), id: \.self) { index in
            CardView(card: Card(suit: .spades, rank: .ace), isFaceUp: false, size: .standard)
              .matchedGeometryEffect(id: "DrawPile_\(index)", in: gameNamespace, isSource: true)
              .offset(x: CGFloat(index) * 2, y: CGFloat(index) * -2)
              .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
          }

          if coordinator.deck.remainingCount == 0 {
            RoundedRectangle(cornerRadius: 12)
              .strokeBorder(.white.opacity(0.1), lineWidth: 2)
              .frame(width: 80, height: 112)  // Standard size approx
          }
        }

        Text("\(coordinator.deck.remainingCount)")
          .font(.system(size: 16, weight: .bold, design: .monospaced))
          .foregroundStyle(.white.opacity(0.9))
          + Text(" LEFT")
          .font(.system(size: 10, weight: .bold))
          .foregroundStyle(.white.opacity(0.5))
      }

      // Discard pile
      VStack(spacing: 12) {
        ZStack {
          if let topCard = coordinator.deck.topDiscardCard {
            // Only show top few discard cards for performance, but logically just one main one needed visually usually
            CardView(card: topCard, isFaceUp: true, size: .standard)
              .matchedGeometryEffect(id: "DiscardAndPlay", in: gameNamespace)
          } else {
            RoundedRectangle(cornerRadius: 12)
              .strokeBorder(.white.opacity(0.1), lineWidth: 2, antialiased: true)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(.white.opacity(0.05))
              )
              .frame(width: 80, height: 112)
              .overlay(
                Image(systemName: "tray.full.fill")
                  .font(.title)
                  .foregroundStyle(.white.opacity(0.2))
              )
          }
        }

        Text("\(coordinator.deck.discardCount)")
          .font(.system(size: 16, weight: .bold, design: .monospaced))
          .foregroundStyle(.white.opacity(0.9))
          + Text(" DISCARD")
          .font(.system(size: 10, weight: .bold))
          .foregroundStyle(.white.opacity(0.5))
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
              withAnimation(.spring(response: 0.3)) {
                showTransition = true
              }
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
struct PlayerIndicator: View {
  let player: Player
  let isCurrentPlayer: Bool

  var body: some View {
    GlassCard {
      VStack(spacing: 10) {
        // Avatar Bloom
        ZStack {
          if isCurrentPlayer {
            Circle()
              .fill(player.color.swiftUIColor)
              .blur(radius: 15)
              .opacity(0.5)
          }

          Image(systemName: player.avatar)
            .font(.system(size: 32))
            .foregroundStyle(isCurrentPlayer ? .white : player.color.swiftUIColor)
            .frame(width: 50, height: 50)
            .background(
              Circle()
                .fill(isCurrentPlayer ? player.color.swiftUIColor : .white.opacity(0.1))
            )
            .overlay(
              Circle()
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
        }

        VStack(spacing: 4) {
          Text(player.name)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .lineLimit(1)

          HStack(spacing: 4) {
            Image(systemName: "menucard.fill")
              .font(.caption2)
            Text("\(player.handCount)")
              .font(.system(size: 12, design: .monospaced))
          }
          .foregroundStyle(.white.opacity(0.6))
        }
      }
    }
    .frame(width: 100, height: 130)
    .scaleEffect(isCurrentPlayer ? 1.05 : 1.0)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(
          isCurrentPlayer ? player.color.swiftUIColor : .clear,
          lineWidth: 2
        )
        .shadow(
          color: isCurrentPlayer ? player.color.swiftUIColor.opacity(0.5) : .clear, radius: 10)
    )
    .animation(.spring(response: 0.3), value: isCurrentPlayer)
  }
}
#Preview {
  let players = [
    Player(name: "Alex", avatar: "star.circle.fill", color: .neonPurple),
    Player(name: "Jordan", avatar: "heart.circle.fill", color: .neonPink),
    Player(name: "Sam", avatar: "bolt.circle.fill", color: .neonTeal),
  ]

  return PassAndPlayGameView(
    players: players,
    deck: Deck.standard(),
    cardsPerPlayer: 7,
    freedomMode: true,
    requireAuth: false
  )
}
