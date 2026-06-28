import SwiftUI

struct HomeView : View{
    @AppStorage("highScore_lightItUp") private var highScore1 = 0
    @AppStorage("highScore_TapFrenzy") private var highScore2 = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                Text("My Games")
                    .font(.system(size: 40, weight: .bold))
                
                // Button 1: Goes to Tap Frenzy
                NavigationLink(destination: TapFrenzyView()) {
                    Text("Tap Frenzy")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 250, height: 80)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                
                // Button 2: Goes to Light It Up
                NavigationLink(destination: LightItUpView()) {
                    Text("Light It Up")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 250, height: 80)
                        .background(Color.orange)
                        .cornerRadius(15)
                }
                
                // Button 3: quiz rush
                NavigationLink(destination: QuizRushView()) {
                    Text("Quiz Rush")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 250, height: 80)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                
                //text for highscore topic
                Text("High Scores")
                    .foregroundColor(Color.secondary)
                
                Text("Light It Up : \(highScore1) | Tap Frenzy : \(highScore2) | Quiz Rush : ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)            }
        }
    }
}

#Preview {
    HomeView()
}
