import Foundation
import Observation
import SwiftUI

// MARK: - Player Model
@Observable
class Player: Identifiable {
    let id: UUID
    var name: String
    var hand: [Card]
    var avatar: String // SF Symbol name or custom image
    var color: PlayerColor
    var score: Int
    
    init(name: String, avatar: String = "person.circle.fill", color: PlayerColor = .blue) {
        self.id = UUID()
        self.name = name
        self.hand = []
        self.avatar = avatar
        self.color = color
        self.score = 0
    }
    
    // MARK: - Hand Management
    
    func addCard(_ card: Card) {
        hand.append(card)
    }
    
    func addCards(_ cards: [Card]) {
        hand.append(contentsOf: cards)
    }
    
    @discardableResult
    func removeCard(_ card: Card) -> Card? {
        if let index = hand.firstIndex(where: { $0.id == card.id }) {
            return hand.remove(at: index)
        }
        return nil
    }
    
    func clearHand() {
        hand.removeAll()
    }
    
    func sortHand(by sortType: HandSortType = .suit) {
        switch sortType {
        case .suit:
            hand.sort { $0.sortValue() < $1.sortValue() }
        case .rank:
            hand.sort { $0.rank.numericValue < $1.rank.numericValue }
        case .value:
            hand.sort { $0.pokerValue < $1.pokerValue }
        }
    }
    
    // MARK: - Computed Properties
    
    var handCount: Int {
        return hand.count
    }
    
    var isEmpty: Bool {
        return hand.isEmpty
    }
}

// MARK: - Hand Sort Types
enum HandSortType {
    case suit    // Group by suit first
    case rank    // Sort by rank value
    case value   // Game-specific value (e.g., poker value)
}

// MARK: - Player Color
enum PlayerColor: String, CaseIterable, Codable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    case pink
    case teal
    
    var swiftUIColor: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        case .pink: return .pink
        case .teal: return .teal
        }
    }
}

// MARK: - Player Avatar Presets
extension Player {
    static let avatarOptions: [String] = [
        "person.circle.fill",
        "star.circle.fill",
        "heart.circle.fill",
        "bolt.circle.fill",
        "flame.circle.fill",
        "crown.fill",
        "gamecontroller.fill",
        "diamond.fill"
    ]
}
