import SwiftUI

// MARK: - Game Detail View
struct GameDetailView: View {
    let game: GameDefinition
    @Environment(\.dismiss) var dismiss
    @State private var showPlayOptions = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "1a472a"), Color(hex: "0d2415")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Quick Info
                    quickInfoSection
                    
                    // Description
                    rulesSection
                    
                    // Win Condition
                    winConditionSection
                    
                    // Tags
                    if let tags = game.tags, !tags.isEmpty {
                        tagsSection(tags)
                    }
                    
                    // Deck Requirements
                    deckRequirementsSection
                    
                    // Play button
                    playButton
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlayOptions) {
            PlayModeSelectionView(game: game)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            HStack {
                Image(systemName: game.category.icon)
                Text(game.category.rawValue)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(hex: "d4af37"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.1), in: Capsule())
            
            // Game name
            Text(game.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // Aliases
            if let aliases = game.aliases, !aliases.isEmpty {
                Text("Also known as: \(aliases.joined(separator: ", "))")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
                    .italic()
            }
        }
    }
    
    // MARK: - Quick Info
    private var quickInfoSection: some View {
        HStack(spacing: 20) {
            // Players
            InfoPill(
                icon: "person.2.fill",
                title: "Players",
                value: "\(game.playerCount.min)-\(game.playerCount.max)"
            )
            
            // Difficulty
            if let difficulty = game.difficulty {
                InfoPill(
                    icon: "chart.bar.fill",
                    title: "Difficulty",
                    value: String(repeating: "⭐", count: difficulty)
                )
            }
            
            // Duration
            if let duration = game.duration {
                InfoPill(
                    icon: duration.icon,
                    title: "Duration",
                    value: duration.rawValue.capitalized
                )
            }
        }
    }
    
    // MARK: - Rules Section
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "How to Play", icon: "book.fill")
            
            Text(game.rulesummary)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(6)
                .padding(16)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Win Condition
    private var winConditionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "How to Win", icon: "trophy.fill")
            
            Text(game.winCondition)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(6)
                .padding(16)
                .background(
                    Color(hex: "d4af37").opacity(0.1),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "d4af37").opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Tags Section
    private func tagsSection(_ tags: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Tags", icon: "tag.fill")
            
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.1), in: Capsule())
                }
            }
        }
    }
    
    // MARK: - Deck Requirements
    private var deckRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Deck Setup", icon: "rectangle.stack.fill")
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    icon: "square.stack.3d.up.fill",
                    text: game.deckRequirements.displayString
                )
                
                if case .fixed(let count) = game.dealPattern.cardsPerPlayer {
                    InfoRow(
                        icon: "hand.draw.fill",
                        text: "\(count) cards per player"
                    )
                } else {
                    InfoRow(
                        icon: "hand.draw.fill",
                        text: "All cards dealt"
                    )
                }
                
                if let communal = game.dealPattern.communalCards, communal > 0 {
                    InfoRow(
                        icon: "square.grid.3x3.fill",
                        text: "\(communal) communal cards"
                    )
                }
            }
            .padding(16)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Play Button
    private var playButton: some View {
        Button {
            HapticsManager.shared.playImpactHaptic(style: .medium)
            showPlayOptions = true
        } label: {
            HStack {
                Text("PLAY THIS GAME")
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
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.system(size: 18, weight: .bold))
        }
        .foregroundStyle(.white)
    }
}

struct InfoPill: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "d4af37"))
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "d4af37"))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

// MARK: - Flow Layout (for tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Play Mode Selection Sheet
struct PlayModeSelectionView: View {
    let game: GameDefinition
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a472a")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Choose Play Mode")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.top)
                    
                    VStack(spacing: 16) {
                        PlayModeButton(
                            icon: "iphone.and.arrow.left.and.arrow.right",
                            title: "Pass & Play",
                            subtitle: "Local Turn-Based"
                        ) {
                            // Navigate to Pass & Play setup
                            dismiss()
                        }
                        
                        PlayModeButton(
                            icon: "network",
                            title: "Online Play",
                            subtitle: "GameCenter Multiplayer"
                        ) {
                            // Navigate to Online setup
                            dismiss()
                        }
                        
                        PlayModeButton(
                            icon: "link",
                            title: "Master Play",
                            subtitle: "Dual Device"
                        ) {
                            // Navigate to Master setup
                            dismiss()
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

struct PlayModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "d4af37"))
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameDetailView(game: GameDefinition(
            id: "poker-tx",
            name: "Texas Hold'em",
            aliases: ["Hold'em", "Texas Poker"],
            category: .classics,
            playerCount: PlayerRange(min: 2, max: 10, recommended: 6),
            deckRequirements: DeckRequirements(numberOfDecks: 1, includeJokers: false, customSubset: nil),
            dealPattern: DealPattern(cardsPerPlayer: .fixed(2), communalCards: 5),
            rulesummary: "2 private cards, 5 communal. Betting rounds: Pre-flop, Flop, Turn, River.",
            winCondition: "Best 5-card hand or last player remaining after others fold.",
            difficulty: 3,
            duration: .medium,
            tags: ["strategy", "bluffing", "betting"]
        ))
    }
}
