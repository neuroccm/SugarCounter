import SwiftUI

struct WeeklyTrendCard: View {
    let trend: InsightEngine.WeeklyTrend

    private var trendIcon: String {
        if trend.isImproving {
            return "arrow.down.circle.fill"
        } else if trend.difference < -3 {
            return "arrow.up.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }

    private var trendColor: Color {
        if trend.isImproving && trend.difference >= 3 {
            return .green
        } else if trend.difference < -3 {
            return .red
        } else {
            return .blue
        }
    }

    private var trendMessage: String {
        if !trend.hasEnoughData {
            return "Track more days to see trends"
        }

        let diff = Int(abs(trend.difference))
        if trend.isImproving && diff >= 3 {
            return "\(diff)g less than last week"
        } else if trend.difference < -3 {
            return "\(diff)g more than last week"
        } else {
            return "Similar to last week"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.cyan)
                Text("Weekly Trend")
                    .font(.headline)
                Spacer()
            }

            if trend.hasEnoughData {
                HStack(spacing: 24) {
                    // This Week
                    VStack(spacing: 4) {
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(trend.thisWeekAverage))g")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("avg/day")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(trend.thisWeekDaysTracked) days")
                            .font(.caption2)
                            .foregroundColor(.tertiary)
                    }
                    .frame(maxWidth: .infinity)

                    // Trend Arrow
                    VStack(spacing: 4) {
                        Image(systemName: trendIcon)
                            .font(.title)
                            .foregroundColor(trendColor)

                        if abs(trend.percentChange) >= 5 {
                            Text("\(Int(abs(trend.percentChange)))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(trendColor)
                        }
                    }

                    // Last Week
                    VStack(spacing: 4) {
                        Text("Last Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(trend.lastWeekAverage))g")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("avg/day")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(trend.lastWeekDaysTracked) days")
                            .font(.caption2)
                            .foregroundColor(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                }

                Text(trendMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(trendColor)
                    .padding(.top, 4)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.largeTitle)
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Track at least 2 days each week to see your trend")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 12)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 20) {
        WeeklyTrendCard(trend: InsightEngine.WeeklyTrend(
            thisWeekAverage: 22,
            lastWeekAverage: 28,
            thisWeekDaysTracked: 5,
            lastWeekDaysTracked: 7
        ))

        WeeklyTrendCard(trend: InsightEngine.WeeklyTrend(
            thisWeekAverage: 30,
            lastWeekAverage: 25,
            thisWeekDaysTracked: 4,
            lastWeekDaysTracked: 6
        ))

        WeeklyTrendCard(trend: InsightEngine.WeeklyTrend(
            thisWeekAverage: 0,
            lastWeekAverage: 0,
            thisWeekDaysTracked: 1,
            lastWeekDaysTracked: 0
        ))
    }
    .padding()
}
