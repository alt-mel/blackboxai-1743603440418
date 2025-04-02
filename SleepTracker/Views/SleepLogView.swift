import SwiftUI

struct SleepLogView: View {
    @EnvironmentObject var sleepDataManager: SleepDataManager
    @State private var sortOrder: SortOrder = .newest
    @State private var showingStats = false
    
    enum SortOrder {
        case newest, oldest, longest, shortest
    }
    
    var sortedSessions: [SleepSession] {
        switch sortOrder {
        case .newest:
            return sleepDataManager.sessions.sorted(by: { $0.startTime > $1.startTime })
        case .oldest:
            return sleepDataManager.sessions.sorted(by: { $0.startTime < $1.startTime })
        case .longest:
            return sleepDataManager.sessions.sorted(by: { $0.duration > $1.duration })
        case .shortest:
            return sleepDataManager.sessions.sorted(by: { $0.duration < $1.duration })
        }
    }
    
    var sleepStats: SleepStatistics {
        SleepStatistics(sessions: sleepDataManager.sessions)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack {
                if sleepDataManager.sessions.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No sleep sessions recorded yet")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                } else {
                    // Stats Button
                    Button(action: { showingStats.toggle() }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Sleep Statistics")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    
                    // Sort Picker
                    Picker("Sort Order", selection: $sortOrder) {
                        Label("Newest", systemImage: "arrow.down").tag(SortOrder.newest)
                        Label("Oldest", systemImage: "arrow.up").tag(SortOrder.oldest)
                        Label("Longest", systemImage: "clock.fill").tag(SortOrder.longest)
                        Label("Shortest", systemImage: "clock").tag(SortOrder.shortest)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Sleep Sessions List
                    List {
                        ForEach(sortedSessions) { session in
                            SleepSessionRow(session: session)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationBarTitle("Sleep Log", displayMode: .inline)
        .sheet(isPresented: $showingStats) {
            StatisticsView(stats: sleepStats)
        }
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        sleepDataManager.deleteSession(at: offsets)
    }
}

struct SleepSessionRow: View {
    let session: SleepSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.blue)
                Text(formatDate(session.startTime))
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                Text(session.durationFormatted)
                    .font(.subheadline)
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.black.opacity(0.8))
        .foregroundColor(.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatisticsView: View {
    let stats: SleepStatistics
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.9).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    StatCard(title: "Average Sleep Duration", value: stats.averageDurationFormatted)
                    StatCard(title: "Longest Sleep", value: stats.longestDurationFormatted)
                    StatCard(title: "Shortest Sleep", value: stats.shortestDurationFormatted)
                    StatCard(title: "Total Sleep Sessions", value: "\(stats.totalSessions)")
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Sleep Statistics")
            .navigationBarTitleDisplayMode(.inline)
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

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
    }
}

struct SleepStatistics {
    let sessions: [SleepSession]
    
    var totalSessions: Int {
        sessions.count
    }
    
    var averageDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0.0) { $0 + $1.duration }
        return total / Double(sessions.count)
    }
    
    var longestDuration: TimeInterval {
        sessions.map { $0.duration }.max() ?? 0
    }
    
    var shortestDuration: TimeInterval {
        sessions.map { $0.duration }.min() ?? 0
    }
    
    var averageDurationFormatted: String {
        formatDuration(averageDuration)
    }
    
    var longestDurationFormatted: String {
        formatDuration(longestDuration)
    }
    
    var shortestDurationFormatted: String {
        formatDuration(shortestDuration)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
}

#Preview {
    NavigationView {
        SleepLogView()
            .environmentObject(SleepDataManager())
    }
}