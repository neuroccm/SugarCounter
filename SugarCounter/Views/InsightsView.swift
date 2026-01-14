import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query private var allEntries: [SugarEntry]
    @Query private var allSettings: [UserSettings]

    private var settings: UserSettings? {
        allSettings.first
    }

    private var dailyGoal: Double {
        settings?.dailyGoal ?? SugarConstants.defaultDailyGoal
    }

    private var cautionThreshold: Double {
        settings?.cautionThreshold ?? SugarConstants.defaultCautionThreshold
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Streak Card
                    StreakCard(
                        currentStreak: currentStreak,
                        longestStreak: longestStreak,
                        dailyGoal: dailyGoal
                    )

                    // Stats Overview
                    StatsOverviewCard(
                        totalDaysTracked: totalDaysTracked,
                        daysUnderGoal: daysUnderGoal,
                        averageDaily: averageDaily,
                        bestDay: bestDay
                    )

                    // Pattern Analysis
                    PatternCard(
                        weekdayAverage: weekdayAverage,
                        weekendAverage: weekendAverage
                    )

                    // Weekly Trend Comparison
                    WeeklyTrendCard(trend: weeklyTrend)

                    // Time of Day Analysis
                    TimeOfDayCard(breakdown: timeBreakdown)

                    // Achievements
                    AchievementsCard(
                        achievements: unlockedAchievements,
                        allAchievements: Achievement.all
                    )
                }
                .padding()
            }
            .navigationTitle("Insights")
        }
    }

    // MARK: - Computed Properties

    private var dailyTotals: [(date: Date, dayId: String, total: Double)] {
        let grouped = Dictionary(grouping: allEntries) { $0.dayIdentifier }
        return grouped.map { (dayId, entries) in
            let total = entries.reduce(0) { $0 + $1.grams }
            let date = entries.first?.timestamp ?? Date()
            return (date, dayId, total)
        }.sorted { $0.date < $1.date }
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Check if today has entries and is under goal
        let todayId = SugarEntry.dayIdentifier(for: checkDate)
        let todayTotal = allEntries.filter { $0.dayIdentifier == todayId }.reduce(0) { $0 + $1.grams }

        // If today has no entries, start checking from yesterday
        if todayTotal == 0 {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        } else if todayTotal > dailyGoal {
            return 0
        } else {
            streak = 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        // Count consecutive days under goal
        while true {
            let dayId = SugarEntry.dayIdentifier(for: checkDate)
            let dayTotal = allEntries.filter { $0.dayIdentifier == dayId }.reduce(0) { $0 + $1.grams }

            if dayTotal > 0 && dayTotal <= dailyGoal {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        return streak
    }

    private var longestStreak: Int {
        guard !dailyTotals.isEmpty else { return 0 }

        var maxStreak = 0
        var currentStreak = 0

        for day in dailyTotals {
            if day.total > 0 && day.total <= dailyGoal {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }

    private var totalDaysTracked: Int {
        Set(allEntries.map { $0.dayIdentifier }).count
    }

    private var daysUnderGoal: Int {
        dailyTotals.filter { $0.total > 0 && $0.total <= dailyGoal }.count
    }

    private var averageDaily: Double {
        let totals = dailyTotals.filter { $0.total > 0 }
        guard !totals.isEmpty else { return 0 }
        return totals.reduce(0) { $0 + $1.total } / Double(totals.count)
    }

    private var bestDay: Double {
        dailyTotals.filter { $0.total > 0 }.map { $0.total }.min() ?? 0
    }

    private var weekdayAverage: Double {
        let calendar = Calendar.current
        let weekdayTotals = dailyTotals.filter { day in
            let weekday = calendar.component(.weekday, from: day.date)
            return weekday >= 2 && weekday <= 6 && day.total > 0
        }
        guard !weekdayTotals.isEmpty else { return 0 }
        return weekdayTotals.reduce(0) { $0 + $1.total } / Double(weekdayTotals.count)
    }

    private var weekendAverage: Double {
        let calendar = Calendar.current
        let weekendTotals = dailyTotals.filter { day in
            let weekday = calendar.component(.weekday, from: day.date)
            return (weekday == 1 || weekday == 7) && day.total > 0
        }
        guard !weekendTotals.isEmpty else { return 0 }
        return weekendTotals.reduce(0) { $0 + $1.total } / Double(weekendTotals.count)
    }

    private var timeBreakdown: InsightEngine.TimeBreakdown {
        InsightEngine.calculateTimeBreakdown(entries: allEntries)
    }

    private var weeklyTrend: InsightEngine.WeeklyTrend {
        InsightEngine.calculateWeeklyTrend(entries: allEntries)
    }

    private var unlockedAchievements: [Achievement] {
        Achievement.all.filter { achievement in
            switch achievement.requirement {
            case .streak(let days):
                return longestStreak >= days
            case .totalDays(let days):
                return totalDaysTracked >= days
            case .daysUnderGoal(let days):
                return daysUnderGoal >= days
            case .perfectWeek:
                return hasCompletedPerfectWeek
            }
        }
    }

    private var hasCompletedPerfectWeek: Bool {
        guard dailyTotals.count >= 7 else { return false }

        // Check for any 7 consecutive days under goal
        var consecutiveDays = 0
        for day in dailyTotals {
            if day.total > 0 && day.total <= dailyGoal {
                consecutiveDays += 1
                if consecutiveDays >= 7 {
                    return true
                }
            } else {
                consecutiveDays = 0
            }
        }
        return false
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let dailyGoal: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Current Streak")
                    .font(.headline)
                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(currentStreak)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(currentStreak > 0 ? .orange : .secondary)
                Text(currentStreak == 1 ? "day" : "days")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }

            Text("under \(Int(dailyGoal))g goal")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            HStack {
                Label("Best: \(longestStreak) days", systemImage: "trophy.fill")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stats Overview Card

struct StatsOverviewCard: View {
    let totalDaysTracked: Int
    let daysUnderGoal: Int
    let averageDaily: Double
    let bestDay: Double

    private var successRate: Double {
        guard totalDaysTracked > 0 else { return 0 }
        return Double(daysUnderGoal) / Double(totalDaysTracked) * 100
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Your Stats")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatBox(
                    title: "Days Tracked",
                    value: "\(totalDaysTracked)",
                    icon: "calendar",
                    color: .blue
                )
                StatBox(
                    title: "Success Rate",
                    value: "\(Int(successRate))%",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                StatBox(
                    title: "Daily Average",
                    value: "\(Int(averageDaily))g",
                    icon: "chart.line.uptrend.xyaxis",
                    color: SugarConstants.statusColor(for: averageDaily)
                )
                StatBox(
                    title: "Best Day",
                    value: bestDay > 0 ? "\(Int(bestDay))g" : "-",
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Pattern Card

struct PatternCard: View {
    let weekdayAverage: Double
    let weekendAverage: Double

    private var difference: Double {
        weekendAverage - weekdayAverage
    }

    private var patternMessage: String {
        if weekdayAverage == 0 && weekendAverage == 0 {
            return "Track more days to see patterns"
        } else if abs(difference) < 3 {
            return "Your intake is consistent throughout the week"
        } else if difference > 0 {
            return "You consume \(Int(abs(difference)))g more on weekends"
        } else {
            return "You consume \(Int(abs(difference)))g less on weekends"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Patterns")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Weekdays")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(weekdayAverage))g")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(SugarConstants.statusColor(for: weekdayAverage))
                    Text("avg/day")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 1, height: 50)

                VStack(spacing: 4) {
                    Text("Weekends")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(weekendAverage))g")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(SugarConstants.statusColor(for: weekendAverage))
                    Text("avg/day")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            Text(patternMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Achievements

enum AchievementRequirement {
    case streak(days: Int)
    case totalDays(days: Int)
    case daysUnderGoal(days: Int)
    case perfectWeek
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requirement: AchievementRequirement

    static let all: [Achievement] = [
        Achievement(
            title: "First Step",
            description: "Track your first day",
            icon: "figure.walk",
            color: .blue,
            requirement: .totalDays(days: 1)
        ),
        Achievement(
            title: "Week Warrior",
            description: "Track for 7 days",
            icon: "calendar.badge.clock",
            color: .green,
            requirement: .totalDays(days: 7)
        ),
        Achievement(
            title: "Monthly Master",
            description: "Track for 30 days",
            icon: "calendar",
            color: .purple,
            requirement: .totalDays(days: 30)
        ),
        Achievement(
            title: "On Fire",
            description: "3-day streak under goal",
            icon: "flame.fill",
            color: .orange,
            requirement: .streak(days: 3)
        ),
        Achievement(
            title: "Unstoppable",
            description: "7-day streak under goal",
            icon: "bolt.fill",
            color: .yellow,
            requirement: .streak(days: 7)
        ),
        Achievement(
            title: "Sugar Master",
            description: "14-day streak under goal",
            icon: "crown.fill",
            color: .pink,
            requirement: .streak(days: 14)
        ),
        Achievement(
            title: "Perfect Week",
            description: "7 consecutive days under goal",
            icon: "star.circle.fill",
            color: .yellow,
            requirement: .perfectWeek
        ),
        Achievement(
            title: "Goal Getter",
            description: "10 days under goal",
            icon: "target",
            color: .red,
            requirement: .daysUnderGoal(days: 10)
        ),
        Achievement(
            title: "Sugar Champion",
            description: "30 days under goal",
            icon: "trophy.fill",
            color: .yellow,
            requirement: .daysUnderGoal(days: 30)
        ),
    ]
}

struct AchievementsCard: View {
    let achievements: [Achievement]
    let allAchievements: [Achievement]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text("Achievements")
                    .font(.headline)
                Spacer()
                Text("\(achievements.count)/\(allAchievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(allAchievements) { achievement in
                    let isUnlocked = achievements.contains { $0.title == achievement.title }
                    AchievementBadge(achievement: achievement, isUnlocked: isUnlocked)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.color.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? achievement.color : .gray)
            }

            Text(achievement.title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [SugarEntry.self, UserSettings.self], inMemory: true)
}
