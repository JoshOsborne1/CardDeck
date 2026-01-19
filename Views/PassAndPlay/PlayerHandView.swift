// MARK: - Player Hand View
import CoreMotion
import SwiftUI

// MARK: - Hand Layout

// MARK: - Motion Manager for Tilt Detection

// MARK: - Preview
struct PlayerHandView: View {
  let coordinator: PassAndPlayCoordinator
  @Environment(\.dismiss) var dismiss

  @State private var selectedCards: Set<UUID> = []
  @State private var handLayout: HandLayout = .fan
  @State private var isBlurred = false
  @State private var peekMode = false
  @State private var inactivityTimer: Timer?

  // Motion manager for tilt detection
  @StateObject private var motionManager = MotionManager()

  var body: some View {
    ZStack {
      // Glass Background
      GlassBackgroundView()

      VStack(spacing: 0) {
        // Header
        headerView
          .padding(.top)

        Spacer()

        // Hand display
        handView
          .blur(radius: isBlurred ? 30 : 0)
          .animation(.easeInOut, value: isBlurred)

        Spacer()

        // Actions
        actionButtons
          .padding(.bottom, 10)

        // End Turn button
        endTurnButton
      }
      .padding()

      // Privacy blur overlay
      if isBlurred {
        ZStack {
          Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()

          Color.black.opacity(0.4)
            .ignoresSafeArea()

          VStack(spacing: 20) {
            Image(systemName: "eye.slash.fill")
              .font(.system(size: 60))
              .foregroundStyle(.white.opacity(0.8))
              .symbolEffect(.pulse)

            Text("Tap to reveal cards")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(.white.opacity(0.9))
          }
        }
        .onTapGesture {
          withAnimation {
            isBlurred = false
          }
          resetInactivityTimer()
        }
        .transition(.opacity)
      }
    }
    .onAppear {
      resetInactivityTimer()
      if coordinator.autoBlurEnabled {
        motionManager.startMonitoring { isTilted in
          if isTilted && !isBlurred {
            withAnimation {
              isBlurred = true
            }
          }
        }
      }
    }
    .onDisappear {
      inactivityTimer?.invalidate()
      motionManager.stopMonitoring()
    }
    .gesture(
      TapGesture()
        .onEnded { _ in
          resetInactivityTimer()
        }
    )
  }

  // MARK: - Header
  private var headerView: some View {
    HStack {
      // Player info
      GlassCard {
        HStack(spacing: 12) {
          Image(systemName: coordinator.currentPlayer.avatar)
            .font(.system(size: 24))
            .foregroundStyle(coordinator.currentPlayer.color.swiftUIColor)
            .shadow(color: coordinator.currentPlayer.color.swiftUIColor.opacity(0.5), radius: 5)

          VStack(alignment: .leading, spacing: 2) {
            Text(coordinator.currentPlayer.name)
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(.white)

            Text("\(coordinator.currentPlayer.handCount) cards")
              .font(.system(size: 12))
              .foregroundStyle(.white.opacity(0.6))
          }
          Spacer()
        }
        .padding(.horizontal, 12)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Spacer()

      // Layout toggle
      Menu {
        Button {
          withAnimation { handLayout = .fan }
        } label: {
          Label("Fan", systemImage: "fan.fill")
        }

        Button {
          withAnimation { handLayout = .grid }
        } label: {
          Label("Grid", systemImage: "square.grid.3x3.fill")
        }

        Button {
          withAnimation { handLayout = .list }
        } label: {
          Label("List", systemImage: "list.bullet")
        }
      } label: {
        Image(systemName: "square.grid.2x2")
          .font(.system(size: 20))
          .foregroundStyle(.white)
          .padding(12)
          .background(Circle().fill(.ultraThinMaterial))
          .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
      }
    }
  }

  // MARK: - Hand Display
  @ViewBuilder
  private var handView: some View {
    switch handLayout {
    case .fan:
      fanLayout
    case .grid:
      gridLayout
    case .list:
      listLayout
    }
  }

  private var fanLayout: some View {
    GeometryReader { geometry in
      let cardCount = coordinator.currentPlayer.hand.count
      let totalWidth = geometry.size.width - 40
      let cardWidth: CGFloat = 100  // Slightly larger for better detail
      let maxSpacing: CGFloat = 50
      let spacing = min(maxSpacing, (totalWidth - cardWidth) / CGFloat(max(1, cardCount - 1)))

      ZStack {
        ForEach(Array(coordinator.currentPlayer.hand.enumerated()), id: \.element.id) {
          index, card in
          // Calculate rotation based on index and count
          let angleStep = 5.0  // Degrees per card
          let totalAngle = Double(cardCount - 1) * angleStep
          let startAngle = -totalAngle / 2
          let angle = startAngle + Double(index) * angleStep

          // Vertical offset for fan arc
          let yOffset = abs(Double(index) - Double(cardCount - 1) / 2.0) * 8.0

          CardView(
            card: card,
            isFaceUp: true,
            isSelected: selectedCards.contains(card.id),
            size: .large
          )
          .rotationEffect(.degrees(angle))
          .offset(x: CGFloat(index - (cardCount - 1) / 2) * spacing, y: CGFloat(yOffset))
          // Lift selected card
          .offset(y: selectedCards.contains(card.id) ? -40 : 0)
          .zIndex(selectedCards.contains(card.id) ? 100 : Double(index))
          .onTapGesture {
            toggleCardSelection(card.id)
            resetInactivityTimer()
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .offset(y: 50)  // Push fan down slightly
    }
  }

  private var gridLayout: some View {
    ScrollView {
      LazyVGrid(
        columns: [
          GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
        ], spacing: 16
      ) {
        ForEach(coordinator.currentPlayer.hand) { card in
          CardView(
            card: card,
            isFaceUp: true,
            isSelected: selectedCards.contains(card.id),
            size: .standard
          )
          .onTapGesture {
            toggleCardSelection(card.id)
            resetInactivityTimer()
          }
        }
      }
      .padding()
    }
  }

  private var listLayout: some View {
    ScrollView {
      VStack(spacing: 12) {
        ForEach(coordinator.currentPlayer.hand) { card in
          GlassCard {
            HStack {
              Text(card.displayName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(card.suit.color)

              Spacer()

              if selectedCards.contains(card.id) {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(Color.neonTeal)
                  .font(.title2)
              }
            }
            .padding(.horizontal)
          }
          .onTapGesture {
            toggleCardSelection(card.id)
            resetInactivityTimer()
          }
        }
      }
      .padding()
    }
  }

  // MARK: - Action Buttons
  private var actionButtons: some View {
    HStack(spacing: 16) {
      GlassButton(title: "Draw", icon: "arrow.down.circle.fill", color: .neonTeal) {
        if let card = coordinator.deck.draw() {
          coordinator.currentPlayer.addCard(card)
          HapticsManager.shared.playDrawCardHaptic()
          SoundManager.shared.playCardDraw()
        }
        resetInactivityTimer()
      }

      GlassButton(title: "Play", icon: "play.circle.fill", color: .neonPurple) {
        if !selectedCards.isEmpty {
          HapticsManager.shared.playCardPlayHaptic()
          SoundManager.shared.playCardPlay()
        }
        playSelectedCards()
        resetInactivityTimer()
      }
      .opacity(selectedCards.isEmpty ? 0.5 : 1.0)
      .disabled(selectedCards.isEmpty)

      GlassButton(title: "Discard", icon: "trash.circle.fill", color: .neonPink) {
        discardSelectedCards()
        resetInactivityTimer()
      }
      .opacity(selectedCards.isEmpty ? 0.5 : 1.0)
      .disabled(selectedCards.isEmpty)
    }
    .padding(.horizontal)
  }

  private var endTurnButton: some View {
    Button {
      HapticsManager.shared.playImpactHaptic(style: .medium)
      coordinator.nextTurn()
      dismiss()
    } label: {
      HStack {
        Text("END TURN")
          .font(.system(size: 18, weight: .bold, design: .rounded))
        Image(systemName: "arrow.right")
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 18)
      .background(
        ZStack {
          Color.black.opacity(0.6)
          Rectangle().fill(.ultraThinMaterial)
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.white.opacity(0.3), lineWidth: 1)
      )
      .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }
    .padding(.horizontal)
    .padding(.bottom, 20)
  }

  // MARK: - Helper Methods
  private func toggleCardSelection(_ cardId: UUID) {
    HapticsManager.shared.playSelectionHaptic()
    if selectedCards.contains(cardId) {
      selectedCards.remove(cardId)
    } else {
      selectedCards.insert(cardId)
    }
  }

  private func playSelectedCards() {
    // In Freedom Mode, allow any play
    // In Rule Mode, validate based on game rules
    for cardId in selectedCards {
      if let card = coordinator.currentPlayer.hand.first(where: { $0.id == cardId }) {
        coordinator.currentPlayer.removeCard(card)
        coordinator.deck.discard(card)
      }
    }
    selectedCards.removeAll()
  }

  private func discardSelectedCards() {
    for cardId in selectedCards {
      if let card = coordinator.currentPlayer.hand.first(where: { $0.id == cardId }) {
        coordinator.currentPlayer.removeCard(card)
        coordinator.deck.discard(card)
      }
    }
    selectedCards.removeAll()
  }

  private func resetInactivityTimer() {
    inactivityTimer?.invalidate()
    inactivityTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
      withAnimation {
        isBlurred = true
      }
    }
  }
}
enum HandLayout {
  case fan, grid, list
}
class MotionManager: ObservableObject {
  private let motionManager = CMMotionManager()
  private var onTilt: ((Bool) -> Void)?

  func startMonitoring(onTilt: @escaping (Bool) -> Void) {
    self.onTilt = onTilt

    guard motionManager.isDeviceMotionAvailable else { return }

    motionManager.deviceMotionUpdateInterval = 0.1
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let motion = motion else { return }

      // Detect if device is laid flat (face down or face up)
      let gravity = motion.gravity
      let isTilted = abs(gravity.z) > 0.9

      self?.onTilt?(isTilted)
    }
  }

  func stopMonitoring() {
    motionManager.stopDeviceMotionUpdates()
  }
}
#Preview {
  let players = [
    Player(name: "Jordan", avatar: "star.circle.fill", color: .neonPurple)
  ]

  let deck = Deck.standard()
  deck.shuffle()

  return PlayerHandView(
    coordinator: PassAndPlayCoordinator(players: players, deck: deck)
  )
}
