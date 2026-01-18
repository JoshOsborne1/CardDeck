import Foundation
import SwiftUI

// MARK: - Card Suit
enum Suit: String, Codable, CaseIterable {
    case spades = "♠"
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"
    case joker = "🃏"
    
    var color: Color {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .spades, .clubs:
            return .black
        case .joker:
            return .purple
        }
    }
}

// MARK: - Card Rank
enum Rank: String, Codable, CaseIterable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"
    case joker = "JOKER"
    
    var numericValue: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten, .jack, .queen, .king: return 10
        case .ace: return 11 // Can be 1 or 11 in context
        case .joker: return 0
        }
    }
}

// MARK: - Card Model
struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let suit: Suit
    let rank: Rank
    var isFaceUp: Bool
    var positionX: CGFloat
    var positionY: CGFloat
    
    init(suit: Suit, rank: Rank, isFaceUp: Bool = false, position: CGPoint = .zero) {
        self.id = UUID()
        self.suit = suit
        self.rank = rank
        self.isFaceUp = isFaceUp
        self.positionX = position.x
        self.positionY = position.y
    }
    
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set {
            positionX = newValue.x
            positionY = newValue.y
        }
    }
    
    // Computed display name
    var displayName: String {
        if suit == .joker {
            return "🃏 Joker"
        }
        return "\(rank.rawValue)\(suit.rawValue)"
    }
    
    // For sorting (e.g., organizing a hand)
    func sortValue() -> Int {
        let suitValue = Suit.allCases.firstIndex(of: suit) ?? 0
        let rankValue = Rank.allCases.firstIndex(of: rank) ?? 0
        return suitValue * 100 + rankValue
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Card Extensions for Common Games
extension Card {
    /// Blackjack value (Ace can be 1 or 11, handled contextually)
    var blackjackValue: Int {
        return rank.numericValue
    }
    
    /// Poker comparison (Ace high)
    var pokerValue: Int {
        switch rank {
        case .ace: return 14
        case .king: return 13
        case .queen: return 12
        case .jack: return 11
        default: return rank.numericValue
        }
    }
}
