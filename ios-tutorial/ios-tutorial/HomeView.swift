import SwiftUI

// MARK: - Main Tab View Container
struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            
            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.white) // Crisp white looks best against glass
        .preferredColorScheme(.dark) // Forces dark mode for best glass contrast
    }
}

// MARK: - Refactored Home View
struct HomeView: View {
    @AppStorage("highScore_lightItUp") private var highScore1 = 0
    @AppStorage("highScore_TapFrenzy") private var highScore2 = 0
    @AppStorage("highScore_QuizRush") private var highScore3 = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Dynamic Liquid Background
                LiquidBackgroundView()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Header
                        HStack {
                            Text("My Games")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // High Scores Glass Panel
                        ScoreBoardView(score1: highScore1, score2: highScore2, score3: highScore3)
                            .padding(.horizontal)
                        
                        // Games List
                        VStack(spacing: 20) {
                            NavigationLink(destination: Text("Tap Frenzy Game").glassBackground()) {
                                GameCardView(title: "Tap Frenzy", icon: "hand.tap.fill", color: .cyan)
                            }
                            
                            NavigationLink(destination: Text("Light It Up Game").glassBackground()) {
                                GameCardView(title: "Light It Up", icon: "bolt.fill", color: .orange)
                            }
                            
                            NavigationLink(destination: Text("Quiz Rush Game").glassBackground()) {
                                GameCardView(title: "Quiz Rush", icon: "brain.head.profile", color: .purple)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Space for TabBar
                    }
                }
            }
        }
    }
}

// MARK: - Liquid Glass UI Components

struct GameCardView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon Bubble
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("Tap to play")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(20)
        // The Glass Effect Modifier
        .modifier(GlassmorphismModifier())
    }
}

struct ScoreBoardView: View {
    let score1: Int
    let score2: Int
    let score3: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("High Scores")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            
            HStack {
                ScoreItem(title: "Light It Up", score: score1, icon: "bolt.fill", color: .orange)
                Spacer()
                ScoreItem(title: "Tap Frenzy", score: score2, icon: "hand.tap.fill", color: .cyan)
                Spacer()
                ScoreItem(title: "Quiz Rush", score: score3, icon: "brain", color: .purple)
            }
        }
        .padding(20)
        .modifier(GlassmorphismModifier())
    }
}

struct ScoreItem: View {
    let title: String
    let score: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)
            Text("\(score)")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Modifiers & Backgrounds

/// Applies the frosted glass look with specular highlights and shadows
struct GlassmorphismModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark) // Ensure materials render dark/frosted
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
                    .blendMode(.overlay)
            )
    }
}

/// Dynamic moving gradient background to make the glass pop
struct LiquidBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Animated Orbs
            Circle()
                .fill(Color.blue)
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: animate ? -100 : 150, y: animate ? -200 : 0)
            
            Circle()
                .fill(Color.purple)
                .blur(radius: 120)
                .frame(width: 350, height: 350)
                .offset(x: animate ? 150 : -100, y: animate ? 200 : -150)
            
            Circle()
                .fill(Color.indigo)
                .blur(radius: 90)
                .frame(width: 200, height: 200)
                .offset(x: animate ? -50 : 50, y: animate ? 50 : 150)
        }
        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
        .onAppear {
            animate = true
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Convenience modifier to apply the background to other tabs
    func glassBackground() -> some View {
        ZStack {
            LiquidBackgroundView()
            self
        }
    }
}

// MARK: - Supporting Views for other tabs
struct StatsView: View {
    var body: some View {
        NavigationStack {
            Text("Stats Overview")
                .font(.title.bold())
                .foregroundStyle(.white)
                .glassBackground()
        }
    }
}

struct MapView: View {
    var body: some View {
        NavigationStack {
            Text("Map View")
                .font(.title.bold())
                .foregroundStyle(.white)
                .glassBackground()
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Profile").listRowBackground(Color.clear)
                    Text("Notifications").listRowBackground(Color.clear)
                } header: {
                    Text("Account").foregroundStyle(.white.opacity(0.8))
                }
            }
            .scrollContentBackground(.hidden)
            .glassBackground()
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    MainTabView()
}
