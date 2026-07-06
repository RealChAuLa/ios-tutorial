import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.shadowColor = .clear

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor(Color.appGreen)
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.appGreen),
            .font: UIFont.appRounded(ofSize: 11, weight: .bold)
        ]
        itemAppearance.normal.iconColor = UIColor.secondaryLabel
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.appRounded(ofSize: 11, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

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
        .tint(.appGreen)
    }
}

// MARK: - Home View
struct HomeView: View {
    @AppStorage("highScore_lightItUp") private var highScore1 = 0
    @AppStorage("highScore_TapFrenzy")  private var highScore2 = 0
    @AppStorage("highScore_QuizRush")   private var highScore3 = 0

    @StateObject private var dailyChallenge = DailyChallengeManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 22) {

                        // ── Header row: title + streak pill ──────────────────
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Let's play!")
                                    .font(.appFont(28))
                                    .foregroundColor(.primary)
                                Text("Pick a game to keep your streak alive")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Streak badge
                            HStack(spacing: 5) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 16, weight: .bold))
                                Text("\(dailyChallenge.streak)")
                                    .font(.appFont(16))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassCard(cornerRadius: 16, tint: .orange)
                        }
                        // Daily Challenge Card
                        DailyChallengeCard(manager: dailyChallenge)
                            .padding(.top, 4)

                        // Game cards
                        VStack(spacing: 14) {
                            GameCard(
                                title: "Tap Frenzy",
                                subtitle: "Fast reflex challenge",
                                icon: "hand.tap.fill",
                                color: .appBlue,
                                colorDark: .appBlueDark,
                                highScore: highScore2,
                                destination: AnyView(TapFrenzyView())
                            )
                            GameCard(
                                title: "Light It Up",
                                subtitle: "Memory & pattern game",
                                icon: "bolt.fill",
                                color: .appGold,
                                colorDark: .appGoldDark,
                                highScore: highScore1,
                                destination: AnyView(LightItUpView())
                            )
                            GameCard(
                                title: "Quiz Rush",
                                subtitle: "Test your knowledge",
                                icon: "brain.head.profile",
                                color: .appGreen,
                                colorDark: .appGreenDark,
                                highScore: highScore3,
                                destination: AnyView(QuizRushView())
                            )
                        }
                    }
                    .padding(20)
                }
                .onAppear {
                    dailyChallenge.updateStreakAndCompletion()
                }
            }
            // No navigation title – "Dashboard" label removed
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Game Card
struct GameCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let colorDark: Color
    let highScore: Int
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {

                // Icon circle
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [color, colorDark],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 2))
                        .shadow(color: colorDark.opacity(0.5), radius: 6, x: 0, y: 4)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                // Text stack
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.appFont(17))
                        .foregroundColor(.primary)           // adapts to dark mode
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.appGold)
                        Text("Best: \(highScore)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)       // high contrast, adapts to dark mode
                    }
                }

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            .padding(14)
            .glassCard(cornerRadius: 20, tint: color)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Creative Daily Challenge Card
struct DailyChallengeCard: View {
    @ObservedObject var manager: DailyChallengeManager
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            if manager.isCompletedToday {
                completedCardView
            } else {
                activeCardView
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.isCompletedToday)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
    
    // MARK: Active Challenge View
    private var activeCardView: some View {
        NavigationLink(destination: manager.destinationView) {
            VStack(alignment: .leading, spacing: 16) {
                // Top Header Badge
                HStack {
                    HStack(spacing: 6) {
                        Text("DAILY CHALLENGE")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .tracking(1.2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.25))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text("Expires in 12h")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Main Content
                HStack(spacing: 16) {
                    // Game Icon Circle with Glow
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [manager.gameColor, manager.gameColorDark],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 68, height: 68)
                            .shadow(color: manager.gameColor.opacity(isPulsing ? 0.8 : 0.3), radius: isPulsing ? 14 : 6, x: 0, y: 4)
                        
                        Image(systemName: manager.gameIcon)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(manager.gameTitle)
                            .font(.appFont(22))
                            .foregroundColor(.white)
                        
                        Text("Play today's featured game to earn extra XP and protect your streak!")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)
                    }
                }
                
                // CTA Button
                HStack {
                    Text("START CHALLENGE")
                        .font(.appFont(15))
                        .foregroundColor(manager.gameColorDark)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(manager.gameColorDark)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.appPurple, Color.appBlue],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                    
                    // Subtle decorative circles
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .offset(x: 120, y: -60)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
            )
            .shadow(color: Color.appPurple.opacity(0.35), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Completed Challenge View
    private var completedCardView: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Text("CHALLENGE COMPLETED")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.25))
                .clipShape(Capsule())
                
                Spacer()
            }
            
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.appGold)
                        .shadow(color: .appGold.opacity(0.6), radius: 8, x: 0, y: 4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Awesome Job!")
                        .font(.appFont(22))
                        .foregroundColor(.white)
                    
                    Text("You completed today's \(manager.gameTitle) challenge with a score of \(manager.todaysScore)!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.white.opacity(0.8))
                Text("Come back tomorrow for a new surprise challenge!")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.appGreen, Color.appGreenDark],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .offset(x: -100, y: 70)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: Color.appGreen.opacity(0.35), radius: 16, x: 0, y: 10)
    }
}

#Preview {
    MainTabView()
}
