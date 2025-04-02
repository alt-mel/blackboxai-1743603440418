import Foundation
import AVFoundation

class AudioService: NSObject, ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var currentSound: Sound?
    @Published private(set) var currentMeditation: Meditation?
    @Published var volume: Float = 0.5 {
        didSet {
            updateVolume()
        }
    }
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var fadeTimer: Timer?
    private var audioEngine: AVAudioEngine?
    private var mixerNode: AVAudioMixerNode?
    private var playerNodes: [AVAudioPlayerNode] = []
    
    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
    }
    
    // MARK: - Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        guard let audioEngine = audioEngine,
              let mixerNode = mixerNode else { return }
        
        audioEngine.attach(mixerNode)
        audioEngine.connect(mixerNode, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Sound Playback
    
    func playSound(_ sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.filename, withExtension: nil) else {
            print("Sound file not found: \(sound.filename)")
            return
        }
        
        // Stop any currently playing sounds
        if currentSound != sound {
            stopAllAudio()
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.numberOfLoops = -1 // Loop indefinitely
            player.volume = volume
            player.prepareToPlay()
            
            audioPlayers[sound.filename] = player
            player.play()
            
            currentSound = sound
            isPlaying = true
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func playMeditation(_ meditation: Meditation) {
        guard let url = Bundle.main.url(forResource: meditation.filename, withExtension: nil) else {
            print("Meditation file not found: \(meditation.filename)")
            return
        }
        
        stopAllAudio()
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.volume = volume
            player.prepareToPlay()
            
            audioPlayers[meditation.filename] = player
            player.play()
            
            currentMeditation = meditation
            isPlaying = true
        } catch {
            print("Failed to play meditation: \(error)")
        }
    }
    
    func mixSounds(_ sounds: [(sound: Sound, volume: Float)]) {
        stopAllAudio()
        
        for (sound, volume) in sounds {
            guard let url = Bundle.main.url(forResource: sound.filename, withExtension: nil) else { continue }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.delegate = self
                player.numberOfLoops = -1
                player.volume = volume
                player.prepareToPlay()
                
                audioPlayers[sound.filename] = player
                player.play()
            } catch {
                print("Failed to mix sound: \(error)")
            }
        }
        
        isPlaying = true
    }
    
    // MARK: - Playback Control
    
    func pause() {
        audioPlayers.values.forEach { $0.pause() }
        isPlaying = false
    }
    
    func resume() {
        audioPlayers.values.forEach { $0.play() }
        isPlaying = true
    }
    
    func stopAllAudio() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        
        audioPlayers.values.forEach { $0.stop() }
        audioPlayers.removeAll()
        
        currentSound = nil
        currentMeditation = nil
        isPlaying = false
    }
    
    func fadeOutAndStop(duration: TimeInterval = 30.0) {
        guard !audioPlayers.isEmpty else { return }
        
        let startVolume = volume
        let volumeReductionPerSecond = startVolume / Float(duration)
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let newVolume = max(0, self.volume - volumeReductionPerSecond)
            self.volume = newVolume
            
            if newVolume <= 0 {
                timer.invalidate()
                self.stopAllAudio()
            }
        }
    }
    
    // MARK: - Volume Control
    
    private func updateVolume() {
        audioPlayers.values.forEach { $0.volume = volume }
    }
    
    // MARK: - Audio File Management
    
    func preloadAudio() {
        // Preload common sounds
        Sound.sampleSounds.forEach { sound in
            if let url = Bundle.main.url(forResource: sound.filename, withExtension: nil) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[sound.filename] = player
                } catch {
                    print("Failed to preload sound: \(error)")
                }
            }
        }
    }
    
    // MARK: - Error Handling
    
    private func handleAudioError(_ error: Error) {
        print("Audio error occurred: \(error.localizedDescription)")
        stopAllAudio()
        // You might want to notify the UI layer about the error
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            // If it was a meditation (non-looping), stop everything
            if currentMeditation != nil {
                DispatchQueue.main.async {
                    self.stopAllAudio()
                }
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            handleAudioError(error)
        }
    }
}

// MARK: - Audio Processing

extension AudioService {
    func applyFadeIn(duration: TimeInterval = 5.0) {
        guard !audioPlayers.isEmpty else { return }
        
        let startVolume: Float = 0.0
        let targetVolume = volume
        let volumeIncreasePerSecond = (targetVolume - startVolume) / Float(duration)
        
        volume = startVolume
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let newVolume = min(targetVolume, self.volume + volumeIncreasePerSecond * 0.1)
            self.volume = newVolume
            
            if newVolume >= targetVolume {
                timer.invalidate()
            }
        }
    }
    
    func crossFade(from oldSound: Sound, to newSound: Sound, duration: TimeInterval = 3.0) {
        guard let oldPlayer = audioPlayers[oldSound.filename] else { return }
        
        // Start playing new sound at zero volume
        playSound(newSound)
        audioPlayers[newSound.filename]?.volume = 0
        
        let steps = 30
        let stepDuration = duration / Double(steps)
        let volumeStep = oldPlayer.volume / Float(steps)
        
        var currentStep = 0
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            
            // Fade out old sound
            oldPlayer.volume = max(0, oldPlayer.volume - volumeStep)
            
            // Fade in new sound
            if let newPlayer = self.audioPlayers[newSound.filename] {
                newPlayer.volume = min(self.volume, Float(currentStep) * volumeStep)
            }
            
            if currentStep >= steps {
                timer.invalidate()
                oldPlayer.stop()
                self.audioPlayers.removeValue(forKey: oldSound.filename)
            }
        }
    }
}