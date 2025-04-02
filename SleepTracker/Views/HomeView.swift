import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sleepDataManager: SleepDataManager
    @StateObject private var audioService = AudioService()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainDashboard()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SoundLibraryView()
                .environmentObject(audioService)
                .tabItem {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Sounds")
                }
                .tag(1)
            
            MeditationView()
                .environmentObject(audioService)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Meditate")
                }
                .tag(2)
            
            SleepLogView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

struct MainDashboard: View {
    @EnvironmentObject var sleepDataManager: SleepDataManager
    @State private var isImageLoading = true
    @State private var backgroundImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BackgroundView(image: $backgroundImage, isLoading: $isImageLoading)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Sleep Status Card
                        if let currentSession = sleepDataManager.currentSession {
                            ActiveSleepCard(startTime: currentSession.startTime)
                        }
                        
                        // Quick Actions
                        QuickActionsGrid()
                        
                        // Sleep Stats
                        if !sleepDataManager.sessions.isEmpty {
                            SleepStatsView(sessions: sleepDataManager.sessions)
                        }
                        
                        // Sleep Tips
                        SleepTipsCarousel()
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Sleep Better", displayMode: .large)
        }
    }
}

struct BackgroundView: View {
    @Binding var image: UIImage?
    @Binding var isLoading: Bool
    private let imageURL = "https://images.unsplash.com/photo-1508182315878-4e74257d26a3"
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.7), .black.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear(perform: loadBackgroundImage)
    }
    
    private func loadBackgroundImage() {
        guard image == nil else { return }
        
        if let cached = ImageLoader.shared.get(forKey: imageURL) {
            self.image = cached
            self.isLoading = false
            return
        }
        
        guard let url = URL(string: imageURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                self.isLoading = false
                ImageLoader.shared.set(image, forKey: imageURL)
            }
        }.resume()
    }
}

struct ActiveSleepCard: View {
    let startTime: Date
    
    var body: some View {
        NavigationLink(destination: SleepTrackingView()) {
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Sleep Session in Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                Text("Started at \(formatTime(startTime))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct QuickActionsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            NavigationLink(destination: SleepTrackingView()) {
                QuickActionCard(
                    icon: "moon.zzz.fill",
                    title: "Track Sleep",
                    color: .blue
                )
            }
            
            NavigationLink(destination: SoundLibraryView()) {
                QuickActionCard(
                    icon: "speaker.wave.2.fill",
                    title: "Sleep Sounds",
                    color: .purple
                )
            }
            
            NavigationLink(destination: MeditationView()) {
                QuickActionCard(
                    icon: "sparkles",
                    title: "Meditate",
                    color: .green
                )
            }
            
            NavigationLink(destination: SleepLogView()) {
                QuickActionCard(
                    icon: "chart.bar.fill",
                    title: "Sleep Stats",
                    color: .orange
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct SleepStatsView: View {
    let sessions: [SleepSession]
    
    private var averageDuration: TimeInterval {
        let total = sessions.reduce(0.0) { $0 + $1.duration }
        return total / Double(sessions.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sleep Stats")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                StatsCard(
                    value: String(format: "%.1f", averageDuration / 3600),
                    label: "Avg Hours",
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatsCard(
                    value: "\(sessions.count)",
                    label: "Sessions",
                    icon: "list.bullet.clipboard",
                    color: .green
                )
            }
        }
    }
}

struct StatsCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct SleepTipsCarousel: View {
    let tips = [
        ("moon.fill", "Maintain a consistent sleep schedule"),
        ("thermometer.sun.fill", "Keep your bedroom cool and dark"),
        ("bed.double.fill", "Invest in a comfortable mattress"),
        ("cup.and.saucer.fill", "Avoid caffeine before bedtime")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sleep Tips")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(tips, id: \.0) { tip in
                        TipCard(icon: tip.0, text: tip.1)
                    }
                }
            }
        }
    }
}

struct TipCard: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

// Color Extension
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
            (a, r, g, b) = (1, 1, 1, 0)
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

#Preview {
    HomeView()
        .environmentObject(SleepDataManager())
}