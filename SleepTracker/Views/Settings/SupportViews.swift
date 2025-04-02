import SwiftUI

struct HelpCenterView: View {
    @State private var searchText = ""
    
    let helpCategories = [
        HelpCategory(
            title: "Getting Started",
            topics: [
                HelpTopic(
                    title: "How to Track Sleep",
                    content: "To track your sleep:\n\n1. Tap 'Start Sleep Tracking' on the home screen\n2. Place your device near your bed\n3. The app will automatically monitor your sleep\n4. When you wake up, tap 'End Sleep Session'"
                ),
                HelpTopic(
                    title: "Using Sleep Sounds",
                    content: "To use sleep sounds:\n\n1. Go to the Sounds tab\n2. Choose from various categories\n3. Tap a sound to play\n4. Adjust volume as needed\n5. Optional: Set a timer for auto-stop"
                ),
                HelpTopic(
                    title: "Setting Up Smart Alarm",
                    content: "Smart Alarm helps wake you during light sleep:\n\n1. Go to Settings > Sleep Goals\n2. Enable Smart Alarm\n3. Set your wake window (15-60 minutes)\n4. Set your desired wake-up time"
                )
            ]
        ),
        HelpCategory(
            title: "Subscription",
            topics: [
                HelpTopic(
                    title: "Premium Features",
                    content: "Premium includes:\n\n• Advanced sleep analytics\n• Full sound library\n• Guided meditations\n• Smart alarm features\n• Detailed sleep reports"
                ),
                HelpTopic(
                    title: "Managing Subscription",
                    content: "To manage your subscription:\n\n1. Go to Settings\n2. Tap 'Subscription'\n3. View or modify your subscription\n4. Cancel or change plan as needed"
                )
            ]
        ),
        HelpCategory(
            title: "Troubleshooting",
            topics: [
                HelpTopic(
                    title: "Sleep Tracking Issues",
                    content: "If sleep tracking isn't working:\n\n1. Ensure device is properly positioned\n2. Check battery optimization settings\n3. Verify permissions are granted\n4. Restart the app\n\nContact support if issues persist."
                ),
                HelpTopic(
                    title: "Audio Problems",
                    content: "If audio isn't working:\n\n1. Check device volume\n2. Verify audio permissions\n3. Test with different sounds\n4. Restart the app\n\nContact support if issues persist."
                )
            ]
        )
    ]
    
    var filteredCategories: [HelpCategory] {
        if searchText.isEmpty {
            return helpCategories
        }
        return helpCategories.map { category in
            HelpCategory(
                title: category.title,
                topics: category.topics.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.content.localizedCaseInsensitiveContains(searchText)
                }
            )
        }.filter { !$0.topics.isEmpty }
    }
    
    var body: some View {
        List {
            ForEach(filteredCategories) { category in
                Section(header: Text(category.title)) {
                    ForEach(category.topics) { topic in
                        NavigationLink(destination: HelpTopicDetailView(topic: topic)) {
                            Text(topic.title)
                        }
                    }
                }
            }
        }
        .navigationTitle("Help Center")
        .searchable(text: $searchText, prompt: "Search help topics")
    }
}

struct HelpTopicDetailView: View {
    let topic: HelpTopic
    @State private var showingContactSupport = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(topic.content)
                    .padding()
                
                Button(action: { showingContactSupport = true }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Contact Support")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle(topic.title)
        .sheet(isPresented: $showingContactSupport) {
            ContactSupportView()
        }
    }
}

struct ContactSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Details")) {
                    TextField("Subject", text: $subject)
                    TextEditor(text: $message)
                        .frame(height: 150)
                }
                
                Section {
                    Button(action: submitSupport) {
                        Text("Submit")
                    }
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Message Sent", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("We'll get back to you as soon as possible.")
            }
        }
    }
    
    private func submitSupport() {
        // Handle support submission
        showingConfirmation = true
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2024")
                        .foregroundColor(.gray)
                    
                    Text("Information We Collect")
                        .font(.headline)
                    
                    Text("We collect information that you provide directly to us, including:")
                    
                    BulletPoint("Sleep tracking data")
                    BulletPoint("Usage statistics")
                    BulletPoint("Device information")
                    BulletPoint("Account information")
                    
                    Text("How We Use Your Information")
                        .font(.headline)
                    
                    Text("We use the information we collect to:")
                    
                    BulletPoint("Provide and improve our services")
                    BulletPoint("Analyze sleep patterns")
                    BulletPoint("Send notifications and updates")
                }
                
                Group {
                    Text("Data Storage")
                        .font(.headline)
                    
                    Text("Your data is stored securely and encrypted. We retain your data for as long as your account is active or as needed to provide services.")
                    
                    Text("Data Sharing")
                        .font(.headline)
                    
                    Text("We do not sell your personal data. We may share anonymized, aggregate data for research purposes.")
                    
                    Text("Your Rights")
                        .font(.headline)
                    
                    Text("You have the right to:")
                    
                    BulletPoint("Access your data")
                    BulletPoint("Correct your data")
                    BulletPoint("Delete your data")
                    BulletPoint("Export your data")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2024")
                        .foregroundColor(.gray)
                    
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    
                    Text("By accessing or using the app, you agree to be bound by these terms.")
                    
                    Text("2. Use License")
                        .font(.headline)
                    
                    Text("We grant you a limited, non-exclusive license to use the app for personal use.")
                    
                    Text("3. Subscription Terms")
                        .font(.headline)
                    
                    Text("Premium features require a subscription. Subscriptions automatically renew unless cancelled.")
                }
                
                Group {
                    Text("4. User Responsibilities")
                        .font(.headline)
                    
                    Text("You agree to:")
                    
                    BulletPoint("Provide accurate information")
                    BulletPoint("Maintain account security")
                    BulletPoint("Use the app as intended")
                    BulletPoint("Comply with applicable laws")
                    
                    Text("5. Limitations")
                        .font(.headline)
                    
                    Text("The app is not a medical device. Consult healthcare professionals for medical advice.")
                    
                    Text("6. Termination")
                        .font(.headline)
                    
                    Text("We reserve the right to terminate or suspend access to our services for violations of these terms.")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .padding(.trailing, 5)
            Text(text)
        }
        .padding(.leading)
    }
}

struct HelpCategory: Identifiable {
    let id = UUID()
    let title: String
    let topics: [HelpTopic]
}

struct HelpTopic: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

#Preview {
    NavigationView {
        HelpCenterView()
    }
}