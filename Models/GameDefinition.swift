import Foundation

// MARK: - Game Definition Model
struct GameDefinition: Codable, Identifiable {
    let id: String
    let name: String
    let aliases: [String]?
    let category: GameCategory
    let playerCount: PlayerRange
    let deckRequirements: DeckRequirements
    let dealPattern: DealPattern
    let rulesummary: String
    let winCondition: String
    let difficulty: Int? // 1-5
    let duration: GameDuration?
    let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, aliases
        case category = "cat"
        case playerCount = "p"
        case deckRequirements = "dk"
        case dealPattern = "dl"
        case rulesummary = "rl"
        case winCondition = "win"
        case difficulty, duration, tags
    }
}

// MARK: - Game Category
enum GameCategory: String, Codable, CaseIterable {
    case classics = "Classics"
    case party = "Party"
    case trickTaking = "Trick-Taking"
    case shedding = "Shedding"
    case matching = "Matching"
    case solitaire = "Solitaire"
    case casino = "Casino"
    case regional = "Regional"
    
    var icon: String {
        switch self {
        case .classics: return "star.fill"
        case .party: return "party.popper.fill"
        case .trickTaking: return "suit.club.fill"
        case .shedding: return "arrow.down.circle.fill"
        case .matching: return "equal.circle.fill"
        case .solitaire: return "person.fill"
        case .casino: return "dollarsign.circle.fill"
        case .regional: return "globe"
        }
    }
}

// MARK: - Player Range
struct PlayerRange: Codable {
    let min: Int
    let max: Int
    let recommended: Int?
    
    enum CodingKeys: String, CodingKey {
        case min, max
        case recommended = "rec"
    }
    
    var displayString: String {
        if let rec = recommended {
            return "\(min)-\(max) players (best: \(rec))"
        }
        return "\(min)-\(max) players"
    }
}

// MARK: - Deck Requirements
struct DeckRequirements: Codable {
    let numberOfDecks: Int
    let includeJokers: Bool
    let customSubset: String?
    
    enum CodingKeys: String, CodingKey {
        case numberOfDecks = "n"
        case includeJokers = "j"
        case customSubset = "s"
    }
    
    var displayString: String {
        var desc = "\(numberOfDecks) deck\(numberOfDecks > 1 ? "s" : "")"
        if includeJokers {
            desc += " with Jokers"
        }
        if let subset = customSubset {
            desc += " (\(subset))"
        }
        return desc
    }
}

// MARK: - Deal Pattern
struct DealPattern: Codable {
    let cardsPerPlayer: DealAmount
    let communalCards: Int?
    
    enum CodingKeys: String, CodingKey {
        case cardsPerPlayer = "cpp"
        case communalCards = "cm"
    }
}

enum DealAmount: Codable {
    case fixed(Int)
    case all
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .fixed(intValue)
        } else if let stringValue = try? container.decode(String.self), stringValue == "all" {
            self = .all
        } else {
            throw DecodingError.typeMismatch(
                DealAmount.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Int or 'all'"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .fixed(let count):
            try container.encode(count)
        case .all:
            try container.encode("all")
        }
    }
}

// MARK: - Game Duration
enum GameDuration: String, Codable {
    case quick
    case medium
    case long
    
    var icon: String {
        switch self {
        case .quick: return "hare.fill"
        case .medium: return "clock.fill"
        case .long: return "tortoise.fill"
        }
    }
}

// MARK: - Game Loader
class GameLoader {
    static let shared = GameLoader()
    
    private var games: [GameDefinition] = []
    
    private init() {
        loadGames()
    }
    
    func loadGames() {
        // Load from JSON file
        guard let url = Bundle.main.url(forResource: "games_sample", withExtension: "json") else {
            print("Games JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            games = try decoder.decode([GameDefinition].self, from: data)
            print("Loaded \(games.count) games")
        } catch {
            print("Failed to load games: \(error)")
        }
    }
    
    func allGames() -> [GameDefinition] {
        return games
    }
    
    func games(in category: GameCategory) -> [GameDefinition] {
        return games.filter { $0.category == category }
    }
    
    func searchGames(query: String) -> [GameDefinition] {
        let lowercaseQuery = query.lowercased()
        return games.filter { game in
            game.name.lowercased().contains(lowercaseQuery) ||
            game.aliases?.contains(where: { $0.lowercased().contains(lowercaseQuery) }) == true
        }
    }
}
