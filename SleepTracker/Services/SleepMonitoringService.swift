import Foundation
import CoreMotion
import AVFoundation
import UserNotifications

class SleepMonitoringService: ObservableObject {
    @Published private(set) var currentStage: SleepStage = .awake
    @Published private(set) var currentCycle: SleepCycle?
    @Published private(set) var cycles: [SleepCycle] = []
    @Published private(set) var qualityFactors = SleepQualityFactors(
        snoring: 0,
        movement: 0,
        roomTemperature: nil,
        roomNoise: nil,
        roomLight: nil,
        heartRate: nil,
        respiratoryRate: nil
    )
    
    private let motionManager = CMMotionManager()
    private var audioEngine: AVAudioEngine?
    private var analysisQueue = DispatchQueue(label: "com.sleeptracker.analysis")
    private var updateTimer: Timer?
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    
    // Analysis parameters
    private let movementThreshold = 0.1
    private let snoringThreshold = 60.0 // dB
    private let stageUpdateInterval: TimeInterval = 300 // 5 minutes
    private let cycleMinDuration: TimeInterval = 900 // 15 minutes
    
    init() {
        setupAudioSession()
        setupMotionDetection()
    }
    
    func startMonitoring() {
        startMotionUpdates()
        startAudioMonitoring()
        startPeriodicUpdates()
    }
    
    func stopMonitoring() -> SleepAnalysisResult {
        stopMotionUpdates()
        stopAudioMonitoring()
        stopPeriodicUpdates()
        
        return generateAnalysis()
    }
    
    // MARK: - Setup Methods
    
    private func setupAudioSession() {
        do {
            recordingSession = AVAudioSession.sharedInstance()
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupMotionDetection() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0
        }
    }
    
    // MARK: - Monitoring Methods
    
    private func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            
            let movement = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            
            self?.updateMovement(magnitude: movement)
        }
    }
    
    private func startAudioMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true)
            
            audioEngine = AVAudioEngine()
            guard let inputNode = audioEngine?.inputNode else { return }
            
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
                self.analysisQueue.async {
                    self.analyzeAudioBuffer(buffer)
                }
            }
            
            try audioEngine?.start()
        } catch {
            print("Error setting up audio monitoring: \(error)")
        }
    }
    
    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: stageUpdateInterval, repeats: true) { [weak self] _ in
            self?.updateSleepStage()
        }
    }
    
    // MARK: - Analysis Methods
    
    private func analyzeAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Calculate audio levels and detect snoring
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = UInt32(buffer.frameLength)
        
        var maxAmplitude: Float = 0
        for i in 0..<Int(frameCount) {
            let amplitude = abs(channelData[i])
            maxAmplitude = max(maxAmplitude, amplitude)
        }
        
        // Convert amplitude to decibels
        let db = 20 * log10(maxAmplitude)
        
        // Update snoring detection
        if db > Float(snoringThreshold) {
            DispatchQueue.main.async {
                self.qualityFactors.snoring += 0.1
                self.qualityFactors.snoring = min(1.0, self.qualityFactors.snoring)
            }
        }
    }
    
    private func updateMovement(magnitude: Double) {
        if magnitude > movementThreshold {
            DispatchQueue.main.async {
                self.qualityFactors.movement += 0.1
                self.qualityFactors.movement = min(1.0, self.qualityFactors.movement)
            }
        }
    }
    
    private func updateSleepStage() {
        let newStage = determineCurrentSleepStage()
        
        if newStage != currentStage {
            // End current cycle if it exists
            if let current = currentCycle {
                cycles.append(current)
            }
            
            // Start new cycle
            currentCycle = SleepCycle(
                id: UUID(),
                stage: newStage,
                startTime: Date(),
                duration: 0
            )
            
            currentStage = newStage
        }
    }
    
    private func determineCurrentSleepStage() -> SleepStage {
        // Simple sleep stage determination based on movement and time
        if qualityFactors.movement > 0.7 {
            return .awake
        }
        
        // Calculate time since sleep start
        let sleepStart = cycles.first?.startTime ?? Date()
        let timeElapsed = Date().timeIntervalSince(sleepStart)
        
        // Simplified sleep cycle estimation
        let cyclePosition = timeElapsed.truncatingRemainder(dividingBy: 90 * 60) // 90-minute cycle
        
        switch cyclePosition {
        case 0..<45*60: // First 45 minutes
            return .light
        case 45*60..<60*60: // Next 15 minutes
            return .deep
        case 60*60..<75*60: // Next 15 minutes
            return .rem
        default:
            return .light
        }
    }
    
    private func generateAnalysis() -> SleepAnalysisResult {
        // End final cycle
        if let current = currentCycle {
            cycles.append(current)
        }
        
        let recommendations = SleepAnalyzer.analyzeSleepQuality(
            cycles: cycles,
            factors: qualityFactors
        )
        
        return SleepAnalysisResult(
            id: UUID(),
            sessionId: UUID(), // This should match the related SleepSession
            date: Date(),
            cycles: cycles,
            qualityFactors: qualityFactors,
            sleepScore: calculateSleepScore(),
            recommendations: recommendations
        )
    }
    
    private func calculateSleepScore() -> Int {
        var score = 100
        
        // Deduct for poor sleep efficiency
        let timeAwake = cycles.filter { $0.stage == .awake }.reduce(0) { $0 + $1.duration }
        let totalTime = cycles.reduce(0) { $0 + $1.duration }
        let efficiency = (totalTime - timeAwake) / totalTime
        
        if efficiency < 0.85 {
            score -= Int((0.85 - efficiency) * 100)
        }
        
        // Deduct for movement and snoring
        score -= Int(qualityFactors.movement * 20)
        score -= Int(qualityFactors.snoring * 20)
        
        return max(0, min(100, score))
    }
    
    // MARK: - Cleanup Methods
    
    private func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func stopAudioMonitoring() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
    }
    
    private func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    deinit {
        stopMonitoring()
    }
}