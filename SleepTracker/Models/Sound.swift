import Foundation

struct Sound: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let category: SoundCategory
    let filename: String
    let duration: TimeInterval
    let isPremium: Bool
    
    enum SoundCategory: String, Codable, CaseIterable {
        case whiteNoise = "White Noise"
        case nature = "Nature"
        case music = "Sleep Music"
        case ambient = "Ambient"
    }
    
    init(id: UUID = UUID(), name: String, category: SoundCategory, filename: String, duration: TimeInterval, isPremium: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.filename = filename
        self.duration = duration
        self.isPremium = isPremium
    }
    
    static func == (lhs: Sound, rhs: Sound) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let sampleSounds: [Sound] = [
        Sound(name: "Ocean Waves", category: .nature, filename: "ocean_waves.mp3", duration: 600),
        Sound(name: "Rain Forest", category: .nature, filename: "rain_forest.mp3", duration: 600),
        Sound(name: "White Noise", category: .whiteNoise, filename: "white_noise.mp3", duration: 600),
        Sound(name: "Pink Noise", category: .whiteNoise, filename: "pink_noise.mp3", duration: 600, isPremium: true),
        Sound(name: "Lullaby", category: .music, filename: "lullaby.mp3", duration: 900, isPremium: true),
        Sound(name: "Gentle Piano", category: .music, filename: "gentle_piano.mp3", duration: 1200, isPremium: true)
    ]
}

struct Meditation: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let duration: TimeInterval
    let filename: String
    let isPremium: Bool
    
    init(id: UUID = UUID(), title: String, description: String, duration: TimeInterval, filename: String, isPremium: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.filename = filename
        self.isPremium = isPremium
    }
    
    static func == (lhs: Meditation, rhs: Meditation) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let sampleMeditations: [Meditation] = [
        Meditation(
            title: "Bedtime Relaxation",
            description: "A gentle guided meditation to help you unwind and prepare for sleep",
            duration: 600,
            filename: "bedtime_relaxation.mp3"
        ),
        Meditation(
            title: "Deep Sleep Journey",
            description: "A calming meditation designed to guide you into deep, restful sleep",
            duration: 1200,
            filename: "deep_sleep_journey.mp3",
            isPremium: true
        ),
        Meditation(
            title: "Stress Release",
            description: "Release tension and anxiety before bedtime",
            duration: 900,
            filename: "stress_release.mp3",
            isPremium: true
        )
    ]
}