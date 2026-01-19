// MARK: - Pass & Play Setup View
import SwiftUI

// MARK: - Player Setup Row

// MARK: - Toggle Row

// MARK: - Deck Type

// MARK: - Preview
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
        GlassBackgroundView()

        ScrollView {
          VStack(spacing: 24) {
            // Players Section
            GlassCard {
              VStack(alignment: .leading, spacing: 16) {
                Text("PLAYERS")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundStyle(.white.opacity(0.6))
                  .tracking(2)

                VStack(spacing: 12) {
                  ForEach(0..<playerNames.count, id: \.self) { index in
                    PlayerSetupRow(
                      playerNumber: index + 1,
                      name: $playerNames[index],
                      onRemove: playerNames.count > 2
                        ? {
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
                          .font(.headline)
                      }
                      .foregroundStyle(Color.neonTeal)
                      .frame(maxWidth: .infinity)
                      .padding()
                      .background(Color.neonTeal.opacity(0.1))
                      .clipShape(RoundedRectangle(cornerRadius: 12))
                      .overlay(
                        RoundedRectangle(cornerRadius: 12)
                          .stroke(Color.neonTeal.opacity(0.3), lineWidth: 1)
                      )
                    }
                  }
                }
              }
            }

            // Deck Configuration
            GlassCard {
              VStack(alignment: .leading, spacing: 16) {
                Text("DECK SETUP")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundStyle(.white.opacity(0.6))
                  .tracking(2)

                VStack(spacing: 12) {
                  // Deck type picker
                  Picker("Deck Type", selection: $selectedDeckType) {
                    ForEach(DeckType.allCases, id: \.self) { type in
                      Text(type.displayName).tag(type)
                    }
                  }
                  .pickerStyle(.menu)
                  .tint(.neonPurple)
                  .padding()
                  .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))

                  // Cards per player
                  HStack {
                    Text("Cards per player:")
                      .font(.body)
                      .foregroundStyle(.white)

                    Spacer()

                    Stepper("\(cardsPerPlayer)", value: $cardsPerPlayer, in: 1...13)
                      .font(.headline)
                      .foregroundStyle(.white)
                  }
                  .padding()
                  .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                }
              }
            }

            // Game Settings
            GlassCard {
              VStack(alignment: .leading, spacing: 16) {
                Text("GAME SETTINGS")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundStyle(.white.opacity(0.6))
                  .tracking(2)

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
            }

            // Start button
            GlassButton(title: "START GAME", icon: "play.fill", color: .neonPurple) {
              startGame()
            }
            .padding(.top, 10)
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
        .background(
          PlayerColor.allCases[(playerNumber - 1) % PlayerColor.allCases.count].swiftUIColor,
          in: Circle())

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
#Preview {
  PassAndPlaySetupView()
}
