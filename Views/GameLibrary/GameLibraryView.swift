import SwiftUI

// MARK: - Game Library View
struct GameLibraryView: View {
    @StateObject private var viewModel = GameLibraryViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: GameCategory? = nil
    
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
                // Search bar
                searchBar
                
                // Category filter
                categoryFilter
                
                // Games grid
                gamesGrid
            }
        }
        .navigationTitle("Game Library")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadGames()
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))
            
            TextField("Search games...", text: $searchText)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top)
        .onChange(of: searchText) { oldValue, newValue in
            viewModel.searchGames(query: newValue)
        }
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" button
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                    viewModel.filterByCategory(nil)
                }
                
                // Category chips
                ForEach(GameCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        viewModel.filterByCategory(category)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    // MARK: - Games Grid
    private var gamesGrid: some View {
        ScrollView {
            if viewModel.filteredGames.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(viewModel.filteredGames) { game in
                        NavigationLink(destination: GameDetailView(game: game)) {
                            GameCardView(game: game)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))
            
            Text("No games found")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            
            if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                    AnyShapeStyle(Color(hex: "d4af37")) :
                    AnyShapeStyle(.white.opacity(0.1)),
                in: Capsule()
            )
        }
    }
}

// MARK: - Game Card View
struct GameCardView: View {
    let game: GameDefinition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with difficulty
            HStack {
                // Category icon
                Image(systemName: game.category.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "d4af37"))
                
                Spacer()
                
                // Difficulty indicator
                if let difficulty = game.difficulty {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(index < difficulty ? Color(hex: "d4af37") : .white.opacity(0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
            
            // Game name
            Text(game.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            // Player count
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
                Text(game.playerCount.displayString)
                    .font(.system(size: 12))
            }
            .foregroundStyle(.white.opacity(0.6))
            
            Spacer()
            
            // Duration
            if let duration = game.duration {
                HStack(spacing: 4) {
                    Image(systemName: duration.icon)
                        .font(.system(size: 12))
                    Text(duration.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .frame(height: 180)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - View Model
@MainActor
class GameLibraryViewModel: ObservableObject {
    @Published var allGames: [GameDefinition] = []
    @Published var filteredGames: [GameDefinition] = []
    
    private var selectedCategory: GameCategory?
    private var searchQuery: String = ""
    
    func loadGames() {
        allGames = GameLoader.shared.allGames()
        filteredGames = allGames
    }
    
    func searchGames(query: String) {
        searchQuery = query
        applyFilters()
    }
    
    func filterByCategory(_ category: GameCategory?) {
        selectedCategory = category
        applyFilters()
    }
    
    private func applyFilters() {
        var games = allGames
        
        // Apply category filter
        if let category = selectedCategory {
            games = games.filter { $0.category == category }
        }
        
        // Apply search filter
        if !searchQuery.isEmpty {
            let lowercased = searchQuery.lowercased()
            games = games.filter { game in
                game.name.lowercased().contains(lowercased) ||
                game.aliases?.contains(where: { $0.lowercased().contains(lowercased) }) == true ||
                game.tags?.contains(where: { $0.lowercased().contains(lowercased) }) == true
            }
        }
        
        filteredGames = games
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameLibraryView()
    }
}
