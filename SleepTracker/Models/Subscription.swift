import Foundation

enum SubscriptionTier: String, Codable {
    case free = "Free"
    case premium = "Premium"
}

struct Subscription: Codable {
    let tier: SubscriptionTier
    let startDate: Date?
    let expirationDate: Date?
    let isActive: Bool
    let price: Decimal
    
    static let premiumPrice: Decimal = 59.99
    
    init(tier: SubscriptionTier = .free, startDate: Date? = nil, expirationDate: Date? = nil) {
        self.tier = tier
        self.startDate = startDate
        self.expirationDate = expirationDate
        self.price = tier == .premium ? Self.premiumPrice : 0
        
        if tier == .free {
            self.isActive = true
        } else if let expirationDate = expirationDate {
            self.isActive = expirationDate > Date()
        } else {
            self.isActive = false
        }
    }
}

struct UserSettings: Codable {
    var subscription: Subscription
    var alarmSettings: AlarmSettings
    var soundSettings: SoundSettings
    var notificationSettings: NotificationSettings
    var sleepGoal: TimeInterval // in hours
    
    init(subscription: Subscription = Subscription(),
         alarmSettings: AlarmSettings = AlarmSettings(),
         soundSettings: SoundSettings = SoundSettings(),
         notificationSettings: NotificationSettings = NotificationSettings(),
         sleepGoal: TimeInterval = 8.0) {
        self.subscription = subscription
        self.alarmSettings = alarmSettings
        self.soundSettings = soundSettings
        self.notificationSettings = notificationSettings
        self.sleepGoal = sleepGoal
    }
}

struct AlarmSettings: Codable {
    var isSmartAlarmEnabled: Bool
    var smartWakeWindow: TimeInterval // minutes before alarm to start looking for light sleep
    var alarmSound: String
    var alarmVolume: Double
    var vibrationEnabled: Bool
    var snoozeEnabled: Bool
    var snoozeDuration: TimeInterval
    
    init(isSmartAlarmEnabled: Bool = true,
         smartWakeWindow: TimeInterval = 30,
         alarmSound: String = "Gentle Rise",
         alarmVolume: Double = 0.7,
         vibrationEnabled: Bool = true,
         snoozeEnabled: Bool = true,
         snoozeDuration: TimeInterval = 9) {
        self.isSmartAlarmEnabled = isSmartAlarmEnabled
        self.smartWakeWindow = smartWakeWindow
        self.alarmSound = alarmSound
        self.alarmVolume = alarmVolume
        self.vibrationEnabled = vibrationEnabled
        self.snoozeEnabled = snoozeEnabled
        self.snoozeDuration = snoozeDuration
    }
}

struct SoundSettings: Codable {
    var volume: Double
    var fadeOutDuration: TimeInterval
    var mixEnabled: Bool
    var activeSound: String?
    var activeMeditation: String?
    
    init(volume: Double = 0.5,
         fadeOutDuration: TimeInterval = 30,
         mixEnabled: Bool = false,
         activeSound: String? = nil,
         activeMeditation: String? = nil) {
        self.volume = volume
        self.fadeOutDuration = fadeOutDuration
        self.mixEnabled = mixEnabled
        self.activeSound = activeSound
        self.activeMeditation = activeMeditation
    }
}

struct NotificationSettings: Codable {
    var bedtimeReminder: Bool
    var bedtimeReminderTime: Date
    var sleepReportEnabled: Bool
    var weeklyInsightsEnabled: Bool
    var communityUpdatesEnabled: Bool
    
    init(bedtimeReminder: Bool = true,
         bedtimeReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date(),
         sleepReportEnabled: Bool = true,
         weeklyInsightsEnabled: Bool = true,
         communityUpdatesEnabled: Bool = true) {
        self.bedtimeReminder = bedtimeReminder
        self.bedtimeReminderTime = bedtimeReminderTime
        self.sleepReportEnabled = sleepReportEnabled
        self.weeklyInsightsEnabled = weeklyInsightsEnabled
        self.communityUpdatesEnabled = communityUpdatesEnabled
    }
}