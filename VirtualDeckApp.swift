// MARK: - Main App Entry Point
import SwiftUI

// MARK: - App State Manager

// MARK: - Game Mode
@main
struct VirtualDeckApp: App {
  @StateObject private var appState = AppState()

  init() {
    // Configure global navigation appearance
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().tintColor = UIColor(Color.neonTeal)
  }

  var body: some Scene {
    WindowGroup {
      DashboardView()
        .environmentObject(appState)
    }
  }
}
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
enum GameMode {
  case online  // GameCenter matchmaking
  case passAndPlay  // Local turn-based
  case masterPlay  // Dual device (Multipeer)
}
