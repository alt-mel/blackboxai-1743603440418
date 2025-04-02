import Foundation
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var error: String?
    
    static let shared = UserManager()
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "userToken"
    private let userKey = "userData"
    
    private init() {
        loadSavedUser()
    }
    
    struct User: Codable {
        let id: String
        var email: String
        var name: String
        var joinDate: Date
        var preferences: UserPreferences
        var subscription: SubscriptionStatus
        
        struct UserPreferences: Codable {
            var sleepGoal: Double
            var bedtime: Date
            var wakeTime: Date
            var notificationsEnabled: Bool
            var theme: String
        }
        
        struct SubscriptionStatus: Codable {
            var isPremium: Bool
            var expiryDate: Date?
            var subscriptionType: String?
        }
    }
    
    func signIn(email: String, password: String) async throws {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would be an API call
        let mockUser = User(
            id: UUID().uuidString,
            email: email,
            name: email.components(separatedBy: "@")[0],
            joinDate: Date(),
            preferences: User.UserPreferences(
                sleepGoal: 8.0,
                bedtime: Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date(),
                wakeTime: Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date(),
                notificationsEnabled: true,
                theme: "dark"
            ),
            subscription: User.SubscriptionStatus(
                isPremium: false,
                expiryDate: nil,
                subscriptionType: nil
            )
        )
        
        await MainActor.run {
            self.currentUser = mockUser
            self.isAuthenticated = true
            self.saveUser(mockUser)
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let newUser = User(
            id: UUID().uuidString,
            email: email,
            name: name,
            joinDate: Date(),
            preferences: User.UserPreferences(
                sleepGoal: 8.0,
                bedtime: Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date(),
                wakeTime: Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date(),
                notificationsEnabled: true,
                theme: "dark"
            ),
            subscription: User.SubscriptionStatus(
                isPremium: false,
                expiryDate: nil,
                subscriptionType: nil
            )
        )
        
        await MainActor.run {
            self.currentUser = newUser
            self.isAuthenticated = true
            self.saveUser(newUser)
        }
    }
    
    func signOut() {
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userKey)
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateUserPreferences(_ preferences: User.UserPreferences) {
        guard var user = currentUser else { return }
        user.preferences = preferences
        currentUser = user
        saveUser(user)
    }
    
    func updateSubscriptionStatus(_ status: User.SubscriptionStatus) {
        guard var user = currentUser else { return }
        user.subscription = status
        currentUser = user
        saveUser(user)
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    private func loadSavedUser() {
        if let userData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
}