import SwiftUI

struct SettingsView: View {
    @State private var showingSubscription = false
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { showingSubscription = true }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Upgrade to Premium")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .red,
                            title: "Notifications"
                        )
                    }
                    
                    NavigationLink(destination: SoundSettingsView()) {
                        SettingsRow(
                            icon: "speaker.wave.2.fill",
                            iconColor: .blue,
                            title: "Sound Settings"
                        )
                    }
                    
                    NavigationLink(destination: SleepGoalsView()) {
                        SettingsRow(
                            icon: "flag.fill",
                            iconColor: .green,
                            title: "Sleep Goals"
                        )
                    }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink(destination: HelpCenterView()) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            iconColor: .purple,
                            title: "Help Center"
                        )
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        SettingsRow(
                            icon: "lock.fill",
                            iconColor: .gray,
                            title: "Privacy Policy"
                        )
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: "Terms of Service"
                        )
                    }
                }
                
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingSubscription) {
            SubscriptionView()
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private func signOut() {
        // Perform sign out actions
        isLoggedIn = false
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(title)
        }
    }
}

#Preview {
    SettingsView()
}