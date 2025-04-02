import SwiftUI

struct SleepGoalsView: View {
    @AppStorage("sleepGoalHours") private var sleepGoalHours: Double = 8.0
    @AppStorage("bedtimeGoal") private var bedtimeGoal = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @AppStorage("wakeupGoal") private var wakeupGoal = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
    @AppStorage("weekendAdjustment") private var weekendAdjustment = true
    @AppStorage("weekendBedtimeOffset") private var weekendBedtimeOffset: Double = 1.0
    
    @State private var showingRecommendations = false
    
    var body: some View {
        List {
            Section(header: Text("Sleep Duration")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Sleep Goal")
                    HStack {
                        Slider(value: $sleepGoalHours, in: 4...12, step: 0.5)
                        Text("\(sleepGoalHours, specifier: "%.1f") hours")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
                
                Button(action: { showingRecommendations = true }) {
                    Text("View Recommendations")
                }
            }
            
            Section(header: Text("Sleep Schedule")) {
                DatePicker("Bedtime",
                          selection: $bedtimeGoal,
                          displayedComponents: .hourAndMinute)
                
                DatePicker("Wake-up Time",
                          selection: $wakeupGoal,
                          displayedComponents: .hourAndMinute)
            }
            
            Section(header: Text("Weekend Adjustment")) {
                Toggle("Adjust for Weekends", isOn: $weekendAdjustment)
                
                if weekendAdjustment {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekend Bedtime Offset")
                        HStack {
                            Slider(value: $weekendBedtimeOffset, in: 0...3, step: 0.5)
                            Text("+\(weekendBedtimeOffset, specifier: "%.1f") hours")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section(header: Text("Smart Features")) {
                NavigationLink(destination: SmartAlarmSettingsView()) {
                    Text("Smart Alarm Settings")
                }
                
                NavigationLink(destination: SleepRoutineView()) {
                    Text("Sleep Routine")
                }
            }
        }
        .navigationTitle("Sleep Goals")
        .sheet(isPresented: $showingRecommendations) {
            SleepRecommendationsView()
        }
    }
}

struct SmartAlarmSettingsView: View {
    @AppStorage("smartAlarmEnabled") private var smartAlarmEnabled = true
    @AppStorage("smartAlarmWindow") private var smartAlarmWindow: Double = 30
    @AppStorage("gradualWakeEnabled") private var gradualWakeEnabled = true
    @AppStorage("gradualWakeDuration") private var gradualWakeDuration: Double = 15
    
    let windowOptions = [15.0, 30.0, 45.0, 60.0]
    let durationOptions = [5.0, 10.0, 15.0, 20.0, 30.0]
    
    var body: some View {
        List {
            Section(header: Text("Smart Alarm")) {
                Toggle("Enable Smart Alarm", isOn: $smartAlarmEnabled)
                
                if smartAlarmEnabled {
                    Picker("Wake Window", selection: $smartAlarmWindow) {
                        ForEach(windowOptions, id: \.self) { minutes in
                            Text("\(Int(minutes)) minutes").tag(minutes)
                        }
                    }
                }
            }
            
            Section(header: Text("Gradual Wake")) {
                Toggle("Enable Gradual Wake", isOn: $gradualWakeEnabled)
                
                if gradualWakeEnabled {
                    Picker("Duration", selection: $gradualWakeDuration) {
                        ForEach(durationOptions, id: \.self) { minutes in
                            Text("\(Int(minutes)) minutes").tag(minutes)
                        }
                    }
                }
            }
            
            Section(footer: Text("Smart Alarm will wake you during your lightest sleep phase within the selected window before your alarm time.")) {
                EmptyView()
            }
        }
        .navigationTitle("Smart Alarm")
    }
}

struct SleepRoutineView: View {
    @State private var routineSteps: [RoutineStep] = [
        RoutineStep(title: "Stop Caffeine", timeOffset: 8, enabled: true),
        RoutineStep(title: "Dim Lights", timeOffset: 2, enabled: true),
        RoutineStep(title: "Start Relaxation", timeOffset: 1, enabled: true),
        RoutineStep(title: "Bedtime", timeOffset: 0, enabled: true)
    ]
    
    var body: some View {
        List {
            Section(header: Text("Evening Routine")) {
                ForEach($routineSteps) { $step in
                    RoutineStepRow(step: $step)
                }
            }
            
            Section {
                Button(action: addNewStep) {
                    Label("Add Step", systemImage: "plus.circle.fill")
                }
            }
            
            Section(footer: Text("Your evening routine helps prepare your body and mind for sleep.")) {
                EmptyView()
            }
        }
        .navigationTitle("Sleep Routine")
    }
    
    private func addNewStep() {
        routineSteps.append(RoutineStep(title: "New Step", timeOffset: 1, enabled: true))
    }
}

struct RoutineStep: Identifiable {
    let id = UUID()
    var title: String
    var timeOffset: Int
    var enabled: Bool
}

struct RoutineStepRow: View {
    @Binding var step: RoutineStep
    
    var body: some View {
        HStack {
            Toggle(isOn: $step.enabled) {
                VStack(alignment: .leading) {
                    Text(step.title)
                        .foregroundColor(step.enabled ? .primary : .gray)
                    Text("\(step.timeOffset) hour\(step.timeOffset == 1 ? "" : "s") before bed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct SleepRecommendationsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recommended Sleep Duration")) {
                    RecommendationRow(
                        age: "Adults (18-64)",
                        duration: "7-9 hours"
                    )
                    RecommendationRow(
                        age: "Older Adults (65+)",
                        duration: "7-8 hours"
                    )
                }
                
                Section(header: Text("Tips for Better Sleep")) {
                    TipRow(
                        title: "Consistent Schedule",
                        description: "Go to bed and wake up at the same time every day"
                    )
                    TipRow(
                        title: "Optimal Environment",
                        description: "Keep your bedroom cool, dark, and quiet"
                    )
                    TipRow(
                        title: "Avoid Screens",
                        description: "Limit exposure to blue light before bedtime"
                    )
                    TipRow(
                        title: "Exercise",
                        description: "Regular exercise can improve sleep quality"
                    )
                }
            }
            .navigationTitle("Recommendations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RecommendationRow: View {
    let age: String
    let duration: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(age)
                .font(.headline)
            Text(duration)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct TipRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        SleepGoalsView()
    }
}