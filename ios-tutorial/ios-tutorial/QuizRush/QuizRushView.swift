//
//  QuizRushView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-28.
//
import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                if viewModel.isGameOver {
                    gameOverScreen
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    switch viewModel.state {
                    case .loading:
                        loadingScreen
                            .transition(.opacity)
                        
                    case .failed:
                        failedScreen
                            .transition(.opacity)
                        
                    case .loaded:
                        if let currentQuestion = viewModel.currentQuestion {
                            gameLayout(for: currentQuestion)
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }
                    }
                }
            }
            .padding(16)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isGameOver)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.state)
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Loading Screen
    private var loadingScreen: some View {
        VStack(spacing: 18) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.appGreen)
            Text("Loading Trivia Rush...")
                .font(.appFont(18))
                .foregroundColor(.secondary)
        }
        .padding(36)
        .glassCard(cornerRadius: 24)
    }
    
    // MARK: - Failed Screen
    private var failedScreen: some View {
        VStack(spacing: 22) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundColor(.appRed)
            Text("Failed to load questions.")
                .font(.appFont(20))
                .foregroundColor(.primary)
            Button("RETRY") {
                Task { await viewModel.load() }
            }
            .buttonStyle(AppButtonStyle(baseColor: .appGreen, shadowColor: .appGreenDark))
            .frame(width: 160)
        }
        .padding(32)
        .glassCard(cornerRadius: 24)
    }
    
    // MARK: - Game Over Screen
    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.appGreen.opacity(0.18))
                    .frame(width: 80, height: 80)
                Image(systemName: "flag.checkered")
                    .font(.system(size: 38))
                    .foregroundColor(.appGreen)
            }
            .padding(.top, 8)
            
            Text("QUIZ COMPLETE!")
                .font(.appFont(28))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Final Score")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.score)")
                        .font(.appFont(26))
                        .foregroundColor(.appGreen)
                }
                
                Divider()
                
                HStack {
                    HStack(spacing: 6) {
                        Text("Final Streak")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(viewModel.streak)")
                        .font(.appFont(22))
                        .foregroundColor(.appOrange)
                }
            }
            .padding(18)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(16)
            
            VStack(spacing: 12) {
                Button("PLAY AGAIN") {
                    Task { await viewModel.resetGame() }
                }
                .buttonStyle(AppButtonStyle(baseColor: .appGreen, shadowColor: .appGreenDark))
                
                ScoreShareButton(
                    gameTitle: "Quiz Rush",
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    accentColor: .appPurple,
                    shadowColor: .appPurpleDark
                )
            }
            .padding(.top, 6)
        }
        .padding(24)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Active Game Layout
    @ViewBuilder
    func gameLayout(for question: TriviaQuestion) -> some View {
        VStack(spacing: 24) {
            // Header Bar
            HStack {
                // Question Progress
                Text("Q\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.appGreenDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.appGreen.opacity(0.18))
                    .cornerRadius(14)
                
                Spacer()
                
                // Streak Pill
                HStack(spacing: 4) {
                    Text("Streak")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.streak > 0 ? .appOrange : .secondary)
                    Text("\(viewModel.streak)")
                        .font(.appFont(16))
                        .foregroundColor(viewModel.streak > 0 ? .appOrange : .secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(viewModel.streak > 0 ? Color.appOrange.opacity(0.15) : Color.primary.opacity(0.06))
                )
                
                // Score Pill
                HStack(spacing: 4) {
                    Text("PTS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.appFont(18))
                        .foregroundColor(.appGreenDark)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appGreen.opacity(0.15))
                )
            }
            .padding(.horizontal, 4)
            
            // Question Card
            VStack {
                Text(question.question)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(22)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .glassCard(cornerRadius: 22)
            
            Spacer()
            
            // Stable Shuffled Answer Buttons
            QuestionAnswerOptionsView(
                question: question,
                questionIndex: viewModel.currentIndex,
                onSelect: { answer in
                    viewModel.handleAnswer(answer)
                }
            )
        }
    }
}

// MARK: - Answer Options Subview (Ensures stability against unnecessary reshuffles)
struct QuestionAnswerOptionsView: View {
    let question: TriviaQuestion
    let questionIndex: Int
    let onSelect: (String) -> Void
    
    @State private var shuffledOptions: [String] = []
    
    var body: some View {
        VStack(spacing: 14) {
            ForEach(shuffledOptions, id: \.self) { answer in
                Button {
                    onSelect(answer)
                } label: {
                    HStack {
                        Text(answer)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundColor(.appGreen)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.appGreen.opacity(0.25), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            setupOptions()
        }
        .onChange(of: questionIndex) { _, _ in
            setupOptions()
        }
    }
    
    private func setupOptions() {
        let all = question.incorrectAnswers + [question.correctAnswer]
        shuffledOptions = all.shuffled()
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
