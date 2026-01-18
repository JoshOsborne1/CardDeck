import SwiftUI

// MARK: - Pass & Play Setup View
struct PassAndPlaySetupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var playerNames: [String] = ["Player 1", "Player 2"]
    @State private var cardsPerPlayer: Int = 7
    @State private var selectedDeckType: DeckType = .standard
    @State private var freedomMode: Bool = false
    @State private var requireAuth: Bool = true
    @State private var showGame: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "1a472a"), Color(hex: "0d2415")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Players Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PLAYERS")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                ForEach(0..<playerNames.count, id: \.self) { index in
                                    PlayerSetupRow(
                                        playerNumber: index + 1,
                                        name: $playerNames[index],
                                        onRemove: playerNames.count > 2 ? {
                                            playerNames.remove(at: index)
                                        } : nil
                                    )
                                }
                                
                                if playerNames.count < 8 {
                                    Button {
                                        playerNames.append("Player \(playerNames.count + 1)")
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add Player")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundStyle(Color(hex: "d4af37"))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        
                        // Deck Configuration
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DECK SETUP")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                // Deck type picker
                                Picker("Deck Type", selection: $selectedDeckType) {
                                    ForEach(DeckType.allCases, id: \.self) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .colorScheme(.dark)
                                
                                // Cards per player
                                HStack {
                                    Text("Cards per player:")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Stepper("\(cardsPerPlayer)", value: $cardsPerPlayer, in: 1...13)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        // Game Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("GAME SETTINGS")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                                .tracking(1)
                            
                            VStack(spacing: 12) {
                                ToggleRow(
                                    icon: "lock.open.fill",
                                    title: "Freedom Mode",
                                    subtitle: "Play without rule enforcement",
                                    isOn: $freedomMode
                                )
                                
                                ToggleRow(
                                    icon: "faceid",
                                    title: "Require Authentication",
                                    subtitle: "Face ID before showing cards",
                                    isOn: $requireAuth
                                )
                            }
                        }
                        
                        // Start button
                        Button {
                            startGame()
                        } label: {
                            HStack {
                                Text("START GAME")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "play.fill")
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "d4af37"), in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "d4af37").opacity(0.5), radius: 20)
                        }
                        .padding(.top, 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Pass & Play Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .fullScreenCover(isPresented: $showGame) {
                PassAndPlayGameView(
                    players: createPlayers(),
                    deck: createDeck(),
                    cardsPerPlayer: cardsPerPlayer,
                    freedomMode: freedomMode,
                    requireAuth: requireAuth
                )
            }
        }
    }
    
    private func createPlayers() -> [Player] {
        return playerNames.enumerated().map { index, name in
            Player(
                name: name,
                avatar: Player.avatarOptions[index % Player.avatarOptions.count],
                color: PlayerColor.allCases[index % PlayerColor.allCases.count]
            )
        }
    }
    
    private func createDeck() -> Deck {
        return selectedDeckType.createDeck()
    }
    
    private func startGame() {
        showGame = true
    }
}

// MARK: - Player Setup Row
struct PlayerSetupRow: View {
    let playerNumber: Int
    @Binding var name: String
    let onRemove: (() -> Void)?
    
    var body: some View {
        HStack {
            // Player number badge
            Text("\(playerNumber)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(PlayerColor.allCases[(playerNumber - 1) % PlayerColor.allCases.count].swiftUIColor, in: Circle())
            
            // Name text field
            TextField("Player \(playerNumber)", text: $name)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            
            // Remove button (if allowed)
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                        .font(.system(size: 24))
                }
            }
        }
    }
}

// MARK: - Toggle Row
struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "d4af37"))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Deck Type
enum DeckType: String, CaseIterable {
    case standard = "Standard"
    case withJokers = "With Jokers"
    case double = "Double Deck"
    case royals = "Royals Only"
    case numbers = "Numbers Only"
    
    var displayName: String {
        rawValue
    }
    
    func createDeck() -> Deck {
        switch self {
        case .standard:
            return Deck.standard()
        case .withJokers:
            return Deck.withJokers()
        case .double:
            return Deck.doubleDeck()
        case .royals:
            return Deck.royalsOnly()
        case .numbers:
            return Deck.numberCardsOnly()
        }
    }
}

// MARK: - Preview
#Preview {
    PassAndPlaySetupView()
}
