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

    // Hardcoded streak for now – wire to your data model as needed
    private let streak = 7

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
                                Text("\(streak)")
                                    .font(.appFont(16))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassCard(cornerRadius: 16, tint: .orange)
                        }

                        // ── Game cards ────────────────────────────────────────
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

#Preview {
    MainTabView()
}
