import SwiftUI
import CoreMotion

// MARK: - Player Hand View
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
            // Background
            LinearGradient(
                colors: [Color(hex: "1a472a"), Color(hex: "0d2415")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                Spacer()
                
                // Hand display
                handView
                    .blur(radius: isBlurred ? 20 : 0)
                
                Spacer()
                
                // Actions
                actionButtons
                
                // End Turn button
                endTurnButton
            }
            .padding()
            
            // Privacy blur overlay
            if isBlurred {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 20) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text("Tap to reveal cards")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            isBlurred = false
                        }
                        resetInactivityTimer()
                    }
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
            HStack(spacing: 12) {
                Image(systemName: coordinator.currentPlayer.avatar)
                    .font(.system(size: 28))
                    .foregroundStyle(coordinator.currentPlayer.color.swiftUIColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(coordinator.currentPlayer.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("\(coordinator.currentPlayer.handCount) cards")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Layout toggle
            Menu {
                Button {
                    handLayout = .fan
                } label: {
                    Label("Fan", systemImage: "fan.fill")
                }
                
                Button {
                    handLayout = .grid
                } label: {
                    Label("Grid", systemImage: "square.grid.3x3.fill")
                }
                
                Button {
                    handLayout = .list
                } label: {
                    Label("List", systemImage: "list.bullet")
                }
            } label: {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.white.opacity(0.1), in: Circle())
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
            let cardWidth: CGFloat = 80
            let maxSpacing: CGFloat = 60
            let spacing = min(maxSpacing, (totalWidth - cardWidth) / CGFloat(max(1, cardCount - 1)))
            
            HStack(spacing: -cardWidth + spacing) {
                ForEach(Array(coordinator.currentPlayer.hand.enumerated()), id: \.element.id) { index, card in
                    CardView(
                        card: card,
                        isFaceUp: true,
                        isSelected: selectedCards.contains(card.id)
                    )
                    .rotationEffect(.degrees(Double(index - cardCount / 2) * 3))
                    .offset(y: selectedCards.contains(card.id) ? -30 : CGFloat(abs(index - cardCount / 2)) * -5)
                    .onTapGesture {
                        toggleCardSelection(card.id)
                        resetInactivityTimer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var gridLayout: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
            ], spacing: 16) {
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
                    HStack {
                        Text(card.displayName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        if selectedCards.contains(card.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(coordinator.currentPlayer.color.swiftUIColor)
                        }
                    }
                    .padding()
                    .background(
                        selectedCards.contains(card.id) ?
                            AnyShapeStyle(coordinator.currentPlayer.color.swiftUIColor.opacity(0.2)) :
                            AnyShapeStyle(.white.opacity(0.1))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
            ActionButton(icon: "arrow.down.circle.fill", title: "Draw") {
                if let card = coordinator.deck.draw() {
                    coordinator.currentPlayer.addCard(card)
                    HapticsManager.shared.playDrawCardHaptic()
                    SoundManager.shared.playCardDraw()
                }
                resetInactivityTimer()
            }
            
            ActionButton(icon: "play.circle.fill", title: "Play") {
                if !selectedCards.isEmpty {
                    HapticsManager.shared.playCardPlayHaptic()
                    SoundManager.shared.playCardPlay()
                }
                playSelectedCards()
                resetInactivityTimer()
            }
            .disabled(selectedCards.isEmpty)
            
            ActionButton(icon: "trash.circle.fill", title: "Discard") {
                discardSelectedCards()
                resetInactivityTimer()
            }
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
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(hex: "d4af37"), in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "d4af37").opacity(0.5), radius: 15)
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

// MARK: - Hand Layout
enum HandLayout {
    case fan, grid, list
}

// MARK: - Action Button Component
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isEnabled ? .white : .white.opacity(0.3))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isEnabled ? AnyShapeStyle(.white.opacity(0.15)) : AnyShapeStyle(.white.opacity(0.05)),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
    }
}

// MARK: - Motion Manager for Tilt Detection
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

// MARK: - Preview
#Preview {
    let players = [
        Player(name: "Jordan", avatar: "star.circle.fill", color: .purple)
    ]
    
    let deck = Deck.standard()
    deck.shuffle()
    
    // Deal cards
    players[0].addCards([
        Card(suit: .hearts, rank: .ace),
        Card(suit: .spades, rank: .king),
        Card(suit: .diamonds, rank: .queen),
        Card(suit: .clubs, rank: .jack),
        Card(suit: .hearts, rank: .ten)
    ])
    
    let coordinator = PassAndPlayCoordinator(players: players, deck: deck)
    coordinator.gameInProgress = true
    coordinator.requireFaceID = false // Disable for preview
    
    return PlayerHandView(coordinator: coordinator)
}
