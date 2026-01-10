import SwiftUI
import SwiftData
import Charts

enum ChartPeriod: String, CaseIterable {
    case week = "Week"
    case twoWeeks = "2 Weeks"
    case threeWeeks = "3 Weeks"
    case month = "Month"

    var days: Int {
        switch self {
        case .week: return 7
        case .twoWeeks: return 14
        case .threeWeeks: return 21
        case .month: return 30
        }
    }
}

struct DaySummary: Identifiable {
    let id = UUID()
    let date: Date
    let dayIdentifier: String
    let total: Double
    let dayLabel: String

    var color: Color {
        SugarConstants.statusColor(for: total)
    }
}

struct ChartView: View {
    @Query private var allEntries: [SugarEntry]
    @State private var selectedPeriod: ChartPeriod = .week
    @State private var selectedDay: DaySummary?

    private var daySummaries: [DaySummary] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -(selectedPeriod.days - 1), to: today)!

        var summaries: [DaySummary] = []
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = selectedPeriod.days <= 7 ? "EEE" : "M/d"

        for dayOffset in 0..<selectedPeriod.days {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            let dayId = SugarEntry.dayIdentifier(for: date)
            let total = allEntries
                .filter { $0.dayIdentifier == dayId }
                .reduce(0) { $0 + $1.grams }

            summaries.append(DaySummary(
                date: date,
                dayIdentifier: dayId,
                total: total,
                dayLabel: dayFormatter.string(from: date)
            ))
        }
        return summaries
    }

    private var maxValue: Double {
        max(daySummaries.map(\.total).max() ?? 0, SugarConstants.dailyGoal + 10)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ChartPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Chart {
                    ForEach(daySummaries) { day in
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Grams", day.total)
                        )
                        .foregroundStyle(day.color.gradient)
                        .cornerRadius(4)
                    }

                    RuleMark(y: .value("Goal", SugarConstants.dailyGoal))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(.red.opacity(0.7))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("\(Int(SugarConstants.dailyGoal))g")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemBackground))
                        }
                }
                .chartYScale(domain: 0...maxValue)
                .chartXAxis {
                    if selectedPeriod == .week {
                        AxisMarks(values: .stride(by: .day)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(date, format: .dateTime.weekday(.abbreviated))
                                        .font(.caption2)
                                }
                            }
                        }
                    } else {
                        AxisMarks(values: .automatic(desiredCount: min(selectedPeriod.days, 10))) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(date, format: .dateTime.month(.defaultDigits).day())
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let grams = value.as(Double.self) {
                                Text("\(Int(grams))")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 280)
                .padding(.horizontal)

                summarySection

                Spacer()
            }
            .navigationTitle("Charts")
            .animation(.easeInOut(duration: 0.3), value: selectedPeriod)
        }
    }

    private var summarySection: some View {
        let totals = daySummaries.map(\.total)
        let average = totals.isEmpty ? 0 : totals.reduce(0, +) / Double(totals.count)
        let daysOverLimit = daySummaries.filter { $0.total > SugarConstants.dailyGoal }.count
        let daysInGreen = daySummaries.filter { $0.total <= SugarConstants.cautionThreshold && $0.total > 0 }.count

        return VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Avg/Day",
                    value: "\(Int(round(average)))g",
                    color: SugarConstants.statusColor(for: average)
                )
                StatCard(
                    title: "Days Over",
                    value: "\(daysOverLimit)",
                    color: daysOverLimit > 0 ? .red : .green
                )
                StatCard(
                    title: "Days Green",
                    value: "\(daysInGreen)",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ChartView()
        .modelContainer(for: SugarEntry.self, inMemory: true)
}
