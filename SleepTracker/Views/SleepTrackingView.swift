import SwiftUI

struct SleepTrackingView: View {
    @EnvironmentObject var sleepDataManager: SleepDataManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingAlert = false
    @State private var lastActiveTime: Date?
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Timer Display
                VStack(spacing: 15) {
                    Text("Sleep Duration")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 60, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 50)
                
                // Animation
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .opacity(0.8)
                    .scaleEffect(1.0 + sin(elapsedTime * 0.5) * 0.1)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: elapsedTime)
                
                Spacer()
                
                // End Button
                Button(action: endTracking) {
                    Text("End Sleep Session")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .navigationBarTitle("Sleep Tracking", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .alert("Sleep Session Ended", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your sleep session has been saved.")
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                handleActiveState()
            case .inactive:
                handleInactiveState()
            case .background:
                handleBackgroundState()
            @unknown default:
                break
            }
        }
        .onAppear {
            startTracking()
        }
        .onDisappear {
            cleanupTimer()
        }
    }
    
    private func startTracking() {
        sleepDataManager.startSession()
        startTimer()
        lastActiveTime = Date()
    }
    
    private func endTracking() {
        cleanupTimer()
        sleepDataManager.endSession()
        showingAlert = true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func cleanupTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleActiveState() {
        if let lastActive = lastActiveTime {
            // Update elapsed time to account for background time
            let additionalTime = Date().timeIntervalSince(lastActive)
            elapsedTime += additionalTime
        }
        lastActiveTime = Date()
        
        // Restart timer if needed
        if timer == nil {
            startTimer()
        }
    }
    
    private func handleInactiveState() {
        lastActiveTime = Date()
    }
    
    private func handleBackgroundState() {
        cleanupTimer()
        lastActiveTime = Date()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    NavigationView {
        SleepTrackingView()
            .environmentObject(SleepDataManager())
    }
}