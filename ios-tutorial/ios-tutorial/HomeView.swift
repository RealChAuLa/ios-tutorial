import SwiftUI

struct HomeView : View{
    var body: some View {
        // NavigationStack is required to move between screens
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
            }
        }
    }
}

#Preview {
    HomeView()
}
