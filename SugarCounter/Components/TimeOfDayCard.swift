import SwiftUI

struct TimeOfDayCard: View {
    let breakdown: InsightEngine.TimeBreakdown

    private var hasData: Bool {
        breakdown.total > 0
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("When You Consume Sugar")
                    .font(.headline)
                Spacer()
            }

            if hasData {
                // Time period breakdown
                HStack(spacing: 0) {
                    TimePeriodBar(
                        period: "Morning",
                        icon: "sunrise.fill",
                        average: breakdown.morning,
                        percentage: breakdown.percentage(for: "morning"),
                        color: .orange
                    )

                    TimePeriodBar(
                        period: "Afternoon",
                        icon: "sun.max.fill",
                        average: breakdown.afternoon,
                        percentage: breakdown.percentage(for: "afternoon"),
                        color: .yellow
                    )

                    TimePeriodBar(
                        period: "Evening",
                        icon: "sunset.fill",
                        average: breakdown.evening,
                        percentage: breakdown.percentage(for: "evening"),
                        color: .purple
                    )

                    TimePeriodBar(
                        period: "Night",
                        icon: "moon.fill",
                        average: breakdown.night,
                        percentage: breakdown.percentage(for: "night"),
                        color: .indigo
                    )
                }

                // Peak time indicator
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                    Text("Peak: \(breakdown.peakPeriod)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            } else {
                Text("Track more entries to see your time patterns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TimePeriodBar: View {
    let period: String
    let icon: String
    let average: Double
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            // Average grams
            Text("\(Int(average))g")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(average > 0 ? .primary : .secondary)

            // Period label
            Text(period)
                .font(.caption2)
                .foregroundColor(.secondary)

            // Percentage bar
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 8, height: 40)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.8))
                        .frame(width: 8, height: max(4, 40 * (percentage / 100)))
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 40)

            // Percentage label
            Text("\(Int(percentage))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        TimeOfDayCard(breakdown: InsightEngine.TimeBreakdown(
            morning: 12,
            afternoon: 18,
            evening: 22,
            night: 3
        ))

        TimeOfDayCard(breakdown: InsightEngine.TimeBreakdown(
            morning: 0,
            afternoon: 0,
            evening: 0,
            night: 0
        ))
    }
    .padding()
}
