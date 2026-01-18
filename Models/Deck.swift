import Foundation
import Observation

// MARK: - Deck Manager
@Observable
class Deck {
    var cards: [Card]
    var discardPile: [Card] = []
    
    // MARK: - Initialization
    init(numberOfDecks: Int = 1, includeJokers: Bool = false, customCards: [Card]? = nil) {
        if let customCards = customCards {
            // Use custom card set
            self.cards = customCards
        } else {
            // Generate standard deck(s)
            var newCards: [Card] = []
            
            for _ in 0..<numberOfDecks {
                for suit in [Suit.spades, .hearts, .diamonds, .clubs] {
                    for rank in Rank.allCases where rank != .joker {
                        newCards.append(Card(suit: suit, rank: rank))
                    }
                }
                
                if includeJokers {
                    newCards.append(Card(suit: .joker, rank: .joker))
                    newCards.append(Card(suit: .joker, rank: .joker))
                }
            }
            
            self.cards = newCards
        }
    }
    
    // MARK: - Deck Operations
    
    /// Shuffle the deck using Fisher-Yates algorithm
    func shuffle() {
        for i in stride(from: cards.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            cards.swapAt(i, j)
        }
    }
    
    /// Draw a single card from the top of the deck
    func draw() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }
    
    /// Draw multiple cards
    func draw(count: Int) -> [Card] {
        var drawnCards: [Card] = []
        for _ in 0..<min(count, cards.count) {
            if let card = draw() {
                drawnCards.append(card)
            }
        }
        return drawnCards
    }
    
    /// Deal cards to multiple players
    func deal(to playerCount: Int, cardsPerPlayer: Int) -> [[Card]] {
        var hands: [[Card]] = Array(repeating: [], count: playerCount)
        
        for round in 0..<cardsPerPlayer {
            for playerIndex in 0..<playerCount {
                if let card = draw() {
                    hands[playerIndex].append(card)
                }
            }
        }
        
        return hands
    }
    
    /// Add card to discard pile
    func discard(_ card: Card) {
        discardPile.append(card)
    }
    
    /// Peek at top card without removing
    func peek() -> Card? {
        return cards.first
    }
    
    /// Return all cards from discard pile to deck (useful for reusing cards)
    func reclaimDiscardPile() {
        cards.append(contentsOf: discardPile)
        discardPile.removeAll()
    }
    
    /// Reset deck to full standard state
    func reset(numberOfDecks: Int = 1, includeJokers: Bool = false) {
        self.cards.removeAll()
        self.discardPile.removeAll()
        
        // Regenerate
        for _ in 0..<numberOfDecks {
            for suit in [Suit.spades, .hearts, .diamonds, .clubs] {
                for rank in Rank.allCases where rank != .joker {
                    cards.append(Card(suit: suit, rank: rank))
                }
            }
            
            if includeJokers {
                cards.append(Card(suit: .joker, rank: .joker))
                cards.append(Card(suit: .joker, rank: .joker))
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var remainingCount: Int {
        return cards.count
    }
    
    var discardCount: Int {
        return discardPile.count
    }
    
    var topDiscardCard: Card? {
        return discardPile.last
    }
}

// MARK: - Preset Deck Configurations
extension Deck {
    /// Standard 52-card poker deck
    static func standard() -> Deck {
        return Deck(numberOfDecks: 1, includeJokers: false)
    }
    
    /// Deck with 2 Jokers (54 cards)
    static func withJokers() -> Deck {
        return Deck(numberOfDecks: 1, includeJokers: true)
    }
    
    /// Double deck for games like Canasta (104 cards + 4 Jokers)
    static func doubleDeck() -> Deck {
        return Deck(numberOfDecks: 2, includeJokers: true)
    }
    
    /// Only royal cards (J, Q, K, A)
    static func royalsOnly() -> Deck {
        let royalRanks: [Rank] = [.jack, .queen, .king, .ace]
        var customCards: [Card] = []
        
        for suit in [Suit.spades, .hearts, .diamonds, .clubs] {
            for rank in royalRanks {
                customCards.append(Card(suit: suit, rank: rank))
            }
        }
        
        return Deck(customCards: customCards)
    }
    
    /// No face cards (2-10 only)
    static func numberCardsOnly() -> Deck {
        let numberRanks: [Rank] = [.two, .three, .four, .five, .six, .seven, .eight, .nine, .ten]
        var customCards: [Card] = []
        
        for suit in [Suit.spades, .hearts, .diamonds, .clubs] {
            for rank in numberRanks {
                customCards.append(Card(suit: suit, rank: rank))
            }
        }
        
        return Deck(customCards: customCards)
    }
}
