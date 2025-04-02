import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan = .annual
    @State private var isProcessing = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    enum SubscriptionPlan {
        case annual
        
        var price: Double {
            switch self {
            case .annual: return 59.99
            }
        }
        
        var pricePerMonth: Double {
            switch self {
            case .annual: return price / 12
            }
        }
        
        var title: String {
            switch self {
            case .annual: return "Annual Plan"
            }
        }
        
        var description: String {
            switch self {
            case .annual: return "Full access to all premium features"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Text("Upgrade to Premium")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Unlock all features and enhance your sleep")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Features
                    FeaturesGrid()
                    
                    // Subscription Plan
                    VStack(spacing: 20) {
                        PlanCard(
                            plan: .annual,
                            isSelected: selectedPlan == .annual,
                            action: { selectedPlan = .annual }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Subscribe Button
                    Button(action: subscribe) {
                        Group {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Subscribe Now")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(isProcessing)
                    .padding(.horizontal)
                    
                    // Terms
                    Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .alert("Subscription Successful", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for subscribing! You now have access to all premium features.")
        }
        .alert("Subscription Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func subscribe() {
        isProcessing = true
        
        // Simulate subscription process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showingSuccessAlert = true
        }
    }
}

struct FeaturesGrid: View {
    let features = [
        ("waveform", "Premium Sounds", "Access to our full library of sleep sounds"),
        ("moon.stars.fill", "Sleep Analysis", "Detailed insights into your sleep patterns"),
        ("bed.double.fill", "Smart Alarm", "Wake up at the optimal time in your sleep cycle"),
        ("person.fill.checkmark", "Personal Coach", "Get personalized recommendations"),
        ("chart.bar.fill", "Advanced Statistics", "Comprehensive sleep tracking data"),
        ("arrow.triangle.2.circlepath.circle.fill", "Sync Across Devices", "Access your data anywhere")
    ]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            ForEach(features, id: \.0) { feature in
                FeatureCard(
                    icon: feature.0,
                    title: feature.1,
                    description: feature.2
                )
            }
        }
        .padding()
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PlanCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(plan.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(plan.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                }
                
                Divider()
                    .background(Color.gray)
                
                HStack {
                    Text("$\(String(format: "%.2f", plan.price))/year")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("($\(String(format: "%.2f", plan.pricePerMonth))/mo)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    SubscriptionView()
}