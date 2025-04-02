import SwiftUI
import Charts

struct SleepStatsChartView: View {
    @EnvironmentObject var sleepDataManager: SleepDataManager
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: SleepMetric = .duration
    
    enum TimeRange {
        case week, month, year
        
        var title: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
    }
    
    enum SleepMetric {
        case duration, quality, efficiency
        
        var title: String {
            switch self {
            case .duration: return "Duration"
            case .quality: return "Quality"
            case .efficiency: return "Efficiency"
            }
        }
    }
    
    var filteredSessions: [SleepSession] {
        let calendar = Calendar.current
        let now = Date()
        
        return sleepDataManager.sessions.filter { session in
            switch selectedTimeRange {
            case .week:
                return calendar.isDate(session.startTime, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(session.startTime, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(session.startTime, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    var chartData: [ChartDataPoint] {
        let groupedSessions = Dictionary(grouping: filteredSessions) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
        
        return groupedSessions.map { date, sessions in
            let value: Double = {
                switch selectedMetric {
                case .duration:
                    let totalDuration = sessions.reduce(0) { $0 + $1.duration }
                    return totalDuration / 3600 // Convert to hours
                case .quality:
                    return Double(sessions.first?.qualityScore ?? 0)
                case .efficiency:
                    let totalSleepTime = sessions.reduce(0) { $0 + $1.duration }
                    let totalTime = sessions.reduce(0) { $0 + $1.totalTime }
                    return (totalSleepTime / totalTime) * 100
                }
            }()
            
            return ChartDataPoint(date: date, value: value)
        }.sorted { $0.date < $1.date }
    }
    
    var averageValue: Double {
        guard !chartData.isEmpty else { return 0 }
        let total = chartData.reduce(0) { $0 + $1.value }
        return total / Double(chartData.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach([TimeRange.week, .month, .year], id: \.self) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Metric Picker
                Picker("Metric", selection: $selectedMetric) {
                    ForEach([SleepMetric.duration, .quality, .efficiency], id: \.self) { metric in
                        Text(metric.title).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Stats Summary
                StatsSummaryView(
                    metric: selectedMetric,
                    average: averageValue,
                    trend: calculateTrend()
                )
                .padding()
                
                // Chart
                ChartView(data: chartData, metric: selectedMetric)
                    .frame(height: 300)
                    .padding()
                
                // Detailed Stats
                DetailedStatsView(sessions: filteredSessions)
                    .padding()
            }
        }
        .navigationTitle("Sleep Statistics")
        .background(Color.black.opacity(0.9))
    }
    
    private func calculateTrend() -> Double {
        guard chartData.count >= 2 else { return 0 }
        let firstHalf = Array(chartData.prefix(chartData.count / 2))
        let secondHalf = Array(chartData.suffix(chartData.count / 2))
        
        let firstAvg = firstHalf.reduce(0) { $0 + $1.value } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0) { $0 + $1.value } / Double(secondHalf.count)
        
        return ((secondAvg - firstAvg) / firstAvg) * 100
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ChartView: View {
    let data: [ChartDataPoint]
    let metric: SleepStatsChartView.SleepMetric
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(.blue)
                
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(.blue.opacity(0.1))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(formatDate(date))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let value = value.as(Double.self) {
                        Text(formatValue(value))
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func formatValue(_ value: Double) -> String {
        switch metric {
        case .duration:
            return String(format: "%.1fh", value)
        case .quality, .efficiency:
            return String(format: "%.0f%%", value)
        }
    }
}

struct StatsSummaryView: View {
    let metric: SleepStatsChartView.SleepMetric
    let average: Double
    let trend: Double
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Average")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(formatValue(average))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Trend")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .foregroundColor(trend >= 0 ? .green : .red)
                    
                    Text(String(format: "%.1f%%", abs(trend)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(trend >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func formatValue(_ value: Double) -> String {
        switch metric {
        case .duration:
            return String(format: "%.1f hours", value)
        case .quality, .efficiency:
            return String(format: "%.0f%%", value)
        }
    }
}

struct DetailedStatsView: View {
    let sessions: [SleepSession]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Detailed Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 15) {
                GridRow {
                    StatLabel("Total Sessions")
                    StatValue("\(sessions.count)")
                }
                
                GridRow {
                    StatLabel("Best Quality")
                    StatValue("\(bestQuality)%")
                }
                
                GridRow {
                    StatLabel("Longest Sleep")
                    StatValue(formatDuration(longestDuration))
                }
                
                GridRow {
                    StatLabel("Average Bedtime")
                    StatValue(formatTime(averageBedtime))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var bestQuality: Int {
        sessions.map { $0.qualityScore }.max() ?? 0
    }
    
    private var longestDuration: TimeInterval {
        sessions.map { $0.duration }.max() ?? 0
    }
    
    private var averageBedtime: Date {
        let total = sessions.reduce(0) { $0 + $1.startTime.timeIntervalSince1970 }
        return Date(timeIntervalSince1970: total / Double(sessions.count))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return String(format: "%dh %dm", hours, minutes)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct StatLabel: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.gray)
    }
}

struct StatValue: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
    }
}

#Preview {
    NavigationView {
        SleepStatsChartView()
            .environmentObject(SleepDataManager())
    }
}