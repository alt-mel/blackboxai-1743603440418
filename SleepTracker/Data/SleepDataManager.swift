import Foundation
import SwiftUI

class SleepDataManager: ObservableObject {
    @Published var sessions: [SleepSession] = []
    @Published var currentSession: SleepSession?
    @Published var error: String?
    
    private let saveKey = "SleepSessions"
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    init() {
        loadSessions()
        setupNotifications()
    }
    
    func startSession() {
        currentSession = SleepSession()
        beginBackgroundTask()
        objectWillChange.send()
    }
    
    private func calculateQualityFactors() -> SleepQualityFactors {
        // TODO: In a real app, these values would come from sensors or user input
        // For now, using sample values
        return SleepQualityFactors(
            snoring: Double.random(in: 0...0.5),      // Sample snoring level
            movement: Double.random(in: 0...0.3),      // Sample movement level
            roomTemperature: 21.0,                     // Ideal room temperature
            roomNoise: Double.random(in: 30...60),     // Sample noise level
            roomLight: Double.random(in: 0...0.2),     // Sample light level
            heartRate: Double.random(in: 60...80),     // Sample heart rate
            respiratoryRate: Double.random(in: 12...16) // Sample respiratory rate
        )
    }

    func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        
        // Validate session before saving
        guard session.isValid else {
            error = "Invalid sleep session: End time must be after start time"
            return
        }
        
        // Calculate and set quality factors
        session.qualityFactors = calculateQualityFactors()
        
        sessions.append(session)
        currentSession = nil
        saveSessions()
        endBackgroundTask()
        objectWillChange.send()
    }
    
    func deleteSession(at indexSet: IndexSet) {
        sessions.remove(atOffsets: indexSet)
        saveSessions()
    }
    
    // Made public to allow saving from views
    func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            self.error = "Error saving sleep sessions: \(error.localizedDescription)"
            print("Error saving sleep sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
        do {
            let decodedSessions = try JSONDecoder().decode([SleepSession].self, from: data)
            // Filter out invalid sessions
            sessions = decodedSessions.filter { $0.isValid }
        } catch {
            self.error = "Error loading sleep sessions: \(error.localizedDescription)"
            print("Error loading sleep sessions: \(error)")
        }
    }
    
    // MARK: - Background Task Handling
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovingToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appMovingToBackground() {
        if currentSession != nil {
            beginBackgroundTask()
        }
    }
    
    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}