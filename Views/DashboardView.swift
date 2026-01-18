import SwiftUI

// MARK: - Main Dashboard View
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient (felt texture theme)
                LinearGradient(
                    colors: [Color(hex: "1a472a"), Color(hex: "0d2415")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // App Title
                    VStack(spacing: 8) {
                        Text("🃏")
                            .font(.system(size: 80))
                        Text("VIRTUAL DECK")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Main Navigation Buttons
                    VStack(spacing: 20) {
                        NavigationButton(
                            icon: "network",
                            title: "ONLINE PLAY",
                            subtitle: "GameCenter Multiplayer",
                            destination: AnyView(Text("Online Play - Coming Soon"))
                        )
                        
                        NavigationButton(
                            icon: "iphone.and.arrow.left.and.arrow.right",
                            title: "PASS & PLAY",
                            subtitle: "Local Turn-Based",
                            destination: AnyView(PassAndPlaySetupView())
                        )
                        
                        NavigationButton(
                            icon: "link",
                            title: "MASTER PLAY",
                            subtitle: "Dual Device Setup",
                            destination: AnyView(Text("Master Play - Coming Soon"))
                        )
                        
                        NavigationButton(
                            icon: "books.vertical.fill",
                            title: "GAME LIBRARY",
                            subtitle: "100+ Card Games",
                            destination: AnyView(GameLibraryView())
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Version info
                    Text("v1.0.0 • Made with ♠️♥️♦️♣️")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Navigation Button Component
struct NavigationButton<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "d4af37")) // Gold accent
                    .frame(width: 50, height: 50)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticsManager.shared.playImpactHaptic(style: .medium)
            }
        )
    }
}

// MARK: - Placeholder Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Display") {
                    Text("Card Style")
                    Text("Theme")
                    Text("Left-Handed Mode")
                }
                
                Section("Sound & Haptics") {
                    Text("Sound Effects")
                    Text("Haptic Feedback")
                }
                
                Section("Privacy") {
                    Text("Screen Timeout")
                    Text("Face ID Lock")
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .environmentObject(AppState())
}
