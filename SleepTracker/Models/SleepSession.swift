import Foundation

struct SleepSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var qualityFactors: SleepQualityFactors?
    
    var qualityScore: Int {
        qualityFactors?.qualityScore ?? 0
    }
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, qualityFactors: SleepQualityFactors? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.qualityFactors = qualityFactors
    }
    
    var duration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        } else {
            // Return current duration for ongoing sessions
            return Date().timeIntervalSince(startTime)
        }
    }
    
    var durationFormatted: String {
        let interval = Int(duration)
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Validation
    var isValid: Bool {
        guard let endTime = endTime else { return true }  // Ongoing sessions are valid
        return endTime > startTime
    }
}