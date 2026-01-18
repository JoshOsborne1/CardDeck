import SwiftUI

// MARK: - Main App Entry Point
@main
struct VirtualDeckApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State Manager
@MainActor
class AppState: ObservableObject {
    @Published var currentGame: GameDefinition?
    @Published var players: [Player] = []
    @Published var deck: Deck = Deck.standard()
    @Published var gameMode: GameMode = .passAndPlay
    @Published var freedomMode: Bool = false
    
    init() {
        // Initialize with default settings
        setupDefaultPlayer()
    }
    
    private func setupDefaultPlayer() {
        let defaultPlayer = Player(
            name: "Player 1",
            avatar: "person.circle.fill",
            color: .blue
        )
        players.append(defaultPlayer)
    }
    
    func resetGame() {
        deck.reset()
        deck.shuffle()
        players.forEach { $0.clearHand() }
    }
}

// MARK: - Game Mode
enum GameMode {
    case online      // GameCenter matchmaking
    case passAndPlay // Local turn-based
    case masterPlay  // Dual device (Multipeer)
}
