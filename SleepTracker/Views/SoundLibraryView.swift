import SwiftUI

struct SoundLibraryView: View {
    @EnvironmentObject var audioService: AudioService
    @State private var selectedCategory: Sound.SoundCategory?
    @State private var showingPremiumAlert = false
    
    private let categories = Sound.SoundCategory.allCases
    private var sounds: [Sound] { Sound.sampleSounds }
    
    var filteredSounds: [Sound] {
        guard let category = selectedCategory else { return sounds }
        return sounds.filter { $0.category == category }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                isSelected: category == selectedCategory,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Sounds Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(filteredSounds) { sound in
                            SoundCard(
                                sound: sound,
                                isPlaying: audioService.currentSound?.id == sound.id,
                                onTap: {
                                    if sound.isPremium {
                                        showingPremiumAlert = true
                                    } else {
                                        playSound(sound)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Sound Library")
        .alert("Premium Feature", isPresented: $showingPremiumAlert) {
            Button("Subscribe") {
                // Handle subscription
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This sound is available for premium subscribers only.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if audioService.isPlaying {
                    Button(action: stopPlayback) {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
    }
    
    private func playSound(_ sound: Sound) {
        audioService.playSound(sound)
    }
    
    private func stopPlayback() {
        audioService.fadeOutAndStop()
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.2))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}

struct SoundCard: View {
    let sound: Sound
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.blue : Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                Text(sound.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if sound.isPremium {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isPlaying ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var categoryIcon: String {
        switch sound.category {
        case .whiteNoise: return "waveform"
        case .nature: return "leaf.fill"
        case .music: return "music.note"
        case .ambient: return "sparkles"
        }
    }
}

#Preview {
    NavigationView {
        SoundLibraryView()
            .environmentObject(AudioService())
    }
}