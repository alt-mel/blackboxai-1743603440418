import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("bedtimeReminder") private var bedtimeReminder = true
    @AppStorage("bedtimeReminderTime") private var bedtimeReminderTime = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @AppStorage("sleepReportEnabled") private var sleepReportEnabled = true
    @AppStorage("weeklyInsightsEnabled") private var weeklyInsightsEnabled = true
    @AppStorage("communityUpdatesEnabled") private var communityUpdatesEnabled = true
    
    var body: some View {
        List {
            Section(header: Text("Bedtime Reminder")) {
                Toggle("Enable Reminder", isOn: $bedtimeReminder)
                
                if bedtimeReminder {
                    DatePicker("Reminder Time",
                             selection: $bedtimeReminderTime,
                             displayedComponents: .hourAndMinute)
                }
            }
            
            Section(header: Text("Sleep Reports")) {
                Toggle("Daily Sleep Report", isOn: $sleepReportEnabled)
                    .onChange(of: sleepReportEnabled) { _ in
                        requestNotificationPermission()
                    }
                
                Toggle("Weekly Sleep Insights", isOn: $weeklyInsightsEnabled)
                    .onChange(of: weeklyInsightsEnabled) { _ in
                        requestNotificationPermission()
                    }
            }
            
            Section(header: Text("Community")) {
                Toggle("Community Updates", isOn: $communityUpdatesEnabled)
                    .onChange(of: communityUpdatesEnabled) { _ in
                        requestNotificationPermission()
                    }
            }
            
            Section(footer: Text("Sleep reports and reminders will be sent as notifications to help you maintain a healthy sleep schedule.")) {
                EmptyView()
            }
        }
        .navigationTitle("Notifications")
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
}