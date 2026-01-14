import SwiftUI

struct SmartInsightCard: View {
    let insight: DailyInsight

    private var iconColor: Color {
        switch insight.type {
        case .weeklyComparison:
            return insight.message.contains("better") ? .green : .orange
        case .paceProjection:
            return insight.message.contains("Great") ? .green : .yellow
        case .timeOfDayPattern:
            return .blue
        case .weekdayVsWeekend:
            return insight.message.contains("less") ? .green : .orange
        case .streakProgress:
            return .orange
        case .goalProximity:
            return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 32)

            Text(insight.message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(iconColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        SmartInsightCard(insight: DailyInsight(
            message: "This week you're averaging 22g - 3g better than last week!",
            icon: "arrow.down.circle.fill",
            type: .weeklyComparison
        ))

        SmartInsightCard(insight: DailyInsight(
            message: "Evening is your peak sugar time at 15g average",
            icon: "clock.fill",
            type: .timeOfDayPattern
        ))

        SmartInsightCard(insight: DailyInsight(
            message: "Your weekend average is 8g higher than weekdays",
            icon: "calendar.badge.exclamationmark",
            type: .weekdayVsWeekend
        ))

        SmartInsightCard(insight: DailyInsight.placeholder)
    }
    .padding()
}
