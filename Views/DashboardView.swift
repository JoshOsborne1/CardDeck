// MARK: - Main Dashboard View
import SwiftUI

// MARK: - Components

// MARK: - Placeholder Settings View (Unchanged logic, just basic UI update if needed, but keeping simple for now)

struct DashboardView: View {
  @EnvironmentObject var appState: AppState
  @State private var showSettings = false

  // Grid layout for game modes
  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        // background
        GlassBackgroundView()

        VStack(spacing: 24) {
          // Header
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("WELCOME TO")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.neonTeal)
                .tracking(2)

              Text("VIRTUAL DECK")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
            }

            Spacer()

            // Settings Button
            Button {
              showSettings = true
            } label: {
              Image(systemName: "gearshape.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                  Circle()
                    .stroke(Color.glassBorder, lineWidth: 1)
                )
            }
          }
          .padding(.horizontal, 24)
          .padding(.top, 20)

          ScrollView {
            VStack(spacing: 24) {
              // Featured / Primary Mode
              NavigationLink(destination: PassAndPlaySetupView()) {
                FeaturedGameCard(
                  title: "PASS & PLAY",
                  subtitle: "Local Multiplayer",
                  icon: "iphone.gen3",
                  gradient: Color.neonGradient
                )
              }

              // Secondary Modes Grid
              LazyVGrid(columns: columns, spacing: 16) {
                NavigationLink(destination: Text("Online Play - Coming Soon")) {
                  StandardGameCard(
                    title: "ONLINE",
                    icon: "globe",
                    color: .neonPurple
                  )
                }

                NavigationLink(destination: Text("Master Play - Coming Soon")) {
                  StandardGameCard(
                    title: "MASTER",
                    icon: "crown.fill",
                    color: .neonPink
                  )
                }
              }

              // Game Library (Wide)
              NavigationLink(destination: GameLibraryView()) {
                LibraryGameCard()
              }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)

            // Version info
            Text("v1.0.0 • Made with ♠️♥️♦️♣️")
              .font(.caption2)
              .foregroundStyle(.white.opacity(0.3))
              .padding(.top, 40)
              .padding(.bottom, 20)
          }
        }
      }
      .sheet(isPresented: $showSettings) {
        SettingsView()
      }
    }
  }
}
struct GlassBackgroundView: View {
  @State private var animateGradient = false

  var body: some View {
    ZStack {
      Color.deepNavy.ignoresSafeArea()

      // Animated background mesh (simplified for now)
      LinearGradient(
        colors: [Color.deepNavy, Color.neonPurple.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      // Circles
      Circle()
        .fill(Color.neonTeal.opacity(0.1))
        .blur(radius: 60)
        .frame(width: 200, height: 200)
        .offset(x: -100, y: -200)

      Circle()
        .fill(Color.neonPurple.opacity(0.1))
        .blur(radius: 60)
        .frame(width: 300, height: 300)
        .offset(x: 100, y: 300)
    }
  }
}
struct FeaturedGameCard: View {
  let title: String
  let subtitle: String
  let icon: String
  let gradient: LinearGradient

  var body: some View {
    GlassCard(padding: 0) {
      HStack {
        VStack(alignment: .leading, spacing: 8) {
          Image(systemName: icon)
            .font(.largeTitle)
            .foregroundStyle(gradient)
            .symbolEffect(.bounce, value: true)

          VStack(alignment: .leading, spacing: 4) {
            Text(title)
              .font(.title2)
              .fontWeight(.bold)
              .foregroundStyle(.white)

            Text(subtitle)
              .font(.subheadline)
              .foregroundStyle(.white.opacity(0.7))
          }
        }
        .padding(24)

        Spacer()

        // Decorative visuals
        Image(systemName: "playingcards.fill")
          .font(.system(size: 80))
          .foregroundStyle(gradient.opacity(0.1))
          .rotationEffect(.degrees(-20))
          .offset(x: 20, y: 10)
      }
      .frame(height: 160)
      .clipShape(RoundedRectangle(cornerRadius: 20))
    }
  }
}
struct StandardGameCard: View {
  let title: String
  let icon: String
  let color: Color

  var body: some View {
    GlassCard(padding: 0) {
      VStack(spacing: 16) {
        Circle()
          .fill(color.opacity(0.1))
          .frame(width: 60, height: 60)
          .overlay(
            Image(systemName: icon)
              .font(.title2)
              .foregroundStyle(color)
          )

        Text(title)
          .font(.headline)
          .fontWeight(.bold)
          .foregroundStyle(.white)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 140)
    }
  }
}
struct LibraryGameCard: View {
  var body: some View {
    GlassCard(padding: 0) {
      HStack(spacing: 20) {
        Image(systemName: "books.vertical.fill")
          .font(.title)
          .foregroundStyle(.white)
          .padding(16)
          .background(Color.white.opacity(0.1))
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 4) {
          Text("GAME LIBRARY")
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.white)

          Text("Browse 100+ Games")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
        }

        Spacer()

        Image(systemName: "chevron.right")
          .foregroundStyle(.white.opacity(0.5))
      }
      .padding(20)
    }
  }
}
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
#Preview {
  DashboardView()
    .environmentObject(AppState())
}
