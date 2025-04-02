import SwiftUI

struct MeditationView: View {
    @EnvironmentObject var audioService: AudioService
    @State private var showingPremiumAlert = false
    @State private var selectedMeditation: Meditation?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var timer: Timer?
    
    private var meditations: [Meditation] { Meditation.sampleMeditations }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                Text("Guided Meditations")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // Meditation List
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(meditations) { meditation in
                            MeditationCard(
                                meditation: meditation,
                                isPlaying: selectedMeditation?.id == meditation.id && isPlaying,
                                progress: selectedMeditation?.id == meditation.id ? progress : 0,
                                onTap: {
                                    handleMeditationTap(meditation)
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Now Playing View
                if let meditation = selectedMeditation {
                    NowPlayingView(
                        meditation: meditation,
                        isPlaying: isPlaying,
                        progress: progress,
                        onPlayPause: togglePlayback,
                        onStop: stopPlayback
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .alert("Premium Feature", isPresented: $showingPremiumAlert) {
            Button("Subscribe") {
                // Handle subscription
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This meditation is available for premium subscribers only.")
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    private func handleMeditationTap(_ meditation: Meditation) {
        if meditation.isPremium {
            showingPremiumAlert = true
            return
        }
        
        if selectedMeditation?.id == meditation.id {
            togglePlayback()
        } else {
            startNewMeditation(meditation)
        }
    }
    
    private func startNewMeditation(_ meditation: Meditation) {
        stopPlayback()
        selectedMeditation = meditation
        audioService.playMeditation(meditation)
        isPlaying = true
        startProgressTimer()
    }
    
    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startProgressTimer()
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func stopPlayback() {
        audioService.stopAllAudio()
        isPlaying = false
        progress = 0
        timer?.invalidate()
        timer = nil
        selectedMeditation = nil
    }
    
    private func startProgressTimer() {
        guard let meditation = selectedMeditation else { return }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if progress >= 1.0 {
                stopPlayback()
            } else {
                progress += 1.0 / meditation.duration
            }
        }
    }
}

struct MeditationCard: View {
    let meditation: Meditation
    let isPlaying: Bool
    let progress: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meditation.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(meditation.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if meditation.isPremium {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    
                    Text(formatDuration(meditation.duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if isPlaying {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                
                if isPlaying {
                    ProgressBar(value: progress)
                        .frame(height: 4)
                        .transition(.opacity)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isPlaying ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct NowPlayingView: View {
    let meditation: Meditation
    let isPlaying: Bool
    let progress: Double
    let onPlayPause: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            ProgressBar(value: progress)
                .frame(height: 4)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Now Playing")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(meditation.title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onStop) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
    }
}

struct ProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * CGFloat(value))
            }
        }
    }
}

#Preview {
    MeditationView()
        .environmentObject(AudioService())
}