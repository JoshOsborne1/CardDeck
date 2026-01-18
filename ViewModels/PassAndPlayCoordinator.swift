import SwiftUI
import LocalAuthentication

// MARK: - Pass & Play Coordinator
@Observable
class PassAndPlayCoordinator {
    var players: [Player]
    var deck: Deck
    var currentPlayerIndex: Int = 0
    var gameInProgress: Bool = false
    var freedomMode: Bool = false
    
    // Privacy settings
    var requireFaceID: Bool = true
    var autoBlurEnabled: Bool = true
    
    init(players: [Player], deck: Deck) {
        self.players = players
        self.deck = deck
    }
    
    var currentPlayer: Player {
        players[currentPlayerIndex]
    }
    
    func nextTurn() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
    func previousTurn() {
        currentPlayerIndex = (currentPlayerIndex - 1 + players.count) % players.count
    }
    
    func dealCards(cardsPerPlayer: Int) {
        // Clear all hands first
        players.forEach { $0.clearHand() }
        
        // Deal cards round-robin style
        for _ in 0..<cardsPerPlayer {
            for player in players {
                if let card = deck.draw() {
                    player.addCard(card)
                }
            }
        }
        
        // Sort each player's hand
        players.forEach { $0.sortHand() }
        
        gameInProgress = true
    }
    
    func resetGame() {
        deck.reset()
        deck.shuffle()
        players.forEach { $0.clearHand() }
        currentPlayerIndex = 0
        gameInProgress = false
    }
    
    // MARK: - Biometric Authentication
    func authenticatePlayer(completion: @escaping (Bool) -> Void) {
        guard requireFaceID else {
            completion(true)
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to view your cards"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            // Fallback to passcode
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Enter your passcode to view your cards"
                
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                    DispatchQueue.main.async {
                        completion(success)
                    }
                }
            } else {
                completion(true) // No authentication available
            }
        }
    }
}
