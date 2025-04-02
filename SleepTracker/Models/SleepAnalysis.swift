import Foundation

enum SleepStage: String, Codable {
    case awake = "Awake"
    case light = "Light Sleep"
    case deep = "Deep Sleep"
    case rem = "REM Sleep"
    
    var description: String {
        switch self {
        case .awake:
            return "You are awake or in very light sleep"
        case .light:
            return "Light sleep stage where you can be easily awakened"
        case .deep:
            return "Deep sleep stage important for physical recovery"
        case .rem:
            return "REM sleep stage important for mental recovery and dreams"
        }
    }
}

struct SleepCycle: Identifiable, Codable {
    let id: UUID
    let stage: SleepStage
    let startTime: Date
    let duration: TimeInterval
    
    var endTime: Date {
        return startTime.addingTimeInterval(duration)
    }
}

struct SleepQualityFactors: Codable {
    var snoring: Double // 0-1 scale
    var movement: Double // 0-1 scale
    var roomTemperature: Double? // in Celsius
    var roomNoise: Double? // in decibels
    var roomLight: Double? // 0-1 scale
    var heartRate: Double? // BPM
    var respiratoryRate: Double? // breaths per minute
    
    var qualityScore: Int {
        var score = 100
        
        // Deduct points for snoring
        score -= Int(snoring * 20)
        
        // Deduct points for excessive movement
        score -= Int(movement * 15)
        
        // Adjust for room conditions if available
        if let temp = roomTemperature {
            if temp < 16 || temp > 24 {
                score -= 10
            }
        }
        
        if let noise = roomNoise {
            if noise > 50 {
                score -= Int((noise - 50) / 5)
            }
        }
        
        return max(0, min(100, score))
    }
}

struct SleepAnalysisResult: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let date: Date
    let cycles: [SleepCycle]
    let qualityFactors: SleepQualityFactors
    let sleepScore: Int
    var recommendations: [SleepRecommendation]
    
    var totalSleepTime: TimeInterval {
        cycles.reduce(0) { $0 + $1.duration }
    }
    
    var timeInStage: [SleepStage: TimeInterval] {
        Dictionary(grouping: cycles, by: { $0.stage })
            .mapValues { cycles in
                cycles.reduce(0) { $0 + $1.duration }
            }
    }
    
    var efficiency: Double {
        let totalTime = totalSleepTime
        let timeAsleep = totalTime - (timeInStage[.awake] ?? 0)
        return timeAsleep / totalTime
    }
}

struct SleepRecommendation: Identifiable, Codable {
    let id: UUID
    let category: RecommendationType
    let title: String
    let description: String
    let priority: Int // 1-5, with 5 being highest priority
    
    enum RecommendationType: String, Codable {
        case schedule = "Sleep Schedule"
        case environment = "Sleep Environment"
        case habits = "Sleep Habits"
        case lifestyle = "Lifestyle"
        case medical = "Medical"
    }
}

class SleepAnalyzer {
    static func analyzeSleepQuality(cycles: [SleepCycle], factors: SleepQualityFactors) -> [SleepRecommendation] {
        var recommendations: [SleepRecommendation] = []
        
        // Analyze sleep duration
        let totalSleepTime = cycles.reduce(0) { $0 + $1.duration }
        if totalSleepTime < 7 * 3600 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                category: .schedule,
                title: "Increase Sleep Duration",
                description: "You're getting less than 7 hours of sleep. Try to gradually adjust your schedule to allow for 7-9 hours of sleep.",
                priority: 5
            ))
        }
        
        // Analyze sleep efficiency
        let timeAwake = cycles.filter { $0.stage == .awake }.reduce(0) { $0 + $1.duration }
        let efficiency = (totalSleepTime - timeAwake) / totalSleepTime
        if efficiency < 0.85 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                category: .habits,
                title: "Improve Sleep Efficiency",
                description: "Your sleep efficiency is below 85%. Consider relaxation techniques before bed and maintaining a consistent sleep schedule.",
                priority: 4
            ))
        }
        
        // Analyze environmental factors
        if factors.roomTemperature.map({ $0 < 16 || $0 > 24 }) ?? false {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                category: .environment,
                title: "Optimize Room Temperature",
                description: "Keep your bedroom temperature between 16-24°C (60-75°F) for optimal sleep.",
                priority: 3
            ))
        }
        
        if factors.snoring > 0.3 {
            recommendations.append(SleepRecommendation(
                id: UUID(),
                category: .medical,
                title: "Address Snoring",
                description: "Significant snoring detected. Consider consulting a healthcare provider to rule out sleep apnea.",
                priority: 4
            ))
        }
        
        return recommendations
    }
}