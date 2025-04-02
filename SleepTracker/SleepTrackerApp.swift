import SwiftUI

@main
struct SleepTrackerApp: App {
    @StateObject private var sleepDataManager = SleepDataManager()
    @StateObject private var audioService = AudioService()
    @StateObject private var sleepMonitoringService = SleepMonitoringService()
    @StateObject private var userManager = UserManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else if !userManager.isAuthenticated {
                AuthenticationView()
            } else {
                HomeView()
                    .environmentObject(sleepDataManager)
                    .environmentObject(audioService)
                    .environmentObject(sleepMonitoringService)
                    .environmentObject(userManager)
            }
        }
    }
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Track Your Sleep",
            description: "Monitor your sleep patterns and get insights into your sleep quality",
            imageName: "moon.stars.fill"
        ),
        OnboardingPage(
            title: "Soothing Sounds",
            description: "Fall asleep faster with our collection of calming sounds and meditations",
            imageName: "speaker.wave.2.fill"
        ),
        OnboardingPage(
            title: "Smart Alarm",
            description: "Wake up naturally during your lightest sleep phase",
            imageName: "alarm.fill"
        ),
        OnboardingPage(
            title: "Sleep Better",
            description: "Get personalized recommendations to improve your sleep quality",
            imageName: "bed.double.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                if currentPage == pages.count - 1 {
                    Button(action: completeOnboarding) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 100)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}