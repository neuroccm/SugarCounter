import Foundation
import SwiftData

/// Types of insights the engine can generate
enum InsightType: CaseIterable {
    case weeklyComparison
    case paceProjection
    case timeOfDayPattern
    case weekdayVsWeekend
    case streakProgress
    case goalProximity
}

/// A personalized insight to display to the user
struct DailyInsight: Identifiable {
    let id = UUID()
    let message: String
    let icon: String
    let type: InsightType

    static let placeholder = DailyInsight(
        message: "Track a few days to unlock personalized insights",
        icon: "lightbulb",
        type: .goalProximity
    )
}

/// Engine that generates personalized insights based on user data
struct InsightEngine {

    // MARK: - Main Entry Point

    /// Generates the most relevant insight for today
    static func generateInsight(
        entries: [SugarEntry],
        currentTotal: Double,
        dailyGoal: Double,
        cautionThreshold: Double
    ) -> DailyInsight {
        // Need at least some data to generate insights
        let uniqueDays = Set(entries.map { $0.dayIdentifier }).count

        if uniqueDays < 2 {
            return DailyInsight.placeholder
        }

        // Try different insight types in priority order
        let insightGenerators: [() -> DailyInsight?] = [
            { weeklyComparisonInsight(entries: entries, dailyGoal: dailyGoal) },
            { paceProjectionInsight(entries: entries, currentTotal: currentTotal, dailyGoal: dailyGoal) },
            { timeOfDayInsight(entries: entries, dailyGoal: dailyGoal) },
            { weekdayVsWeekendInsight(entries: entries, dailyGoal: dailyGoal) },
            { streakInsight(entries: entries, dailyGoal: dailyGoal) }
        ]

        for generator in insightGenerators {
            if let insight = generator() {
                return insight
            }
        }

        return DailyInsight.placeholder
    }

    // MARK: - Weekly Comparison

    private static func weeklyComparisonInsight(entries: [SugarEntry], dailyGoal: Double) -> DailyInsight? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let thisWeekStart = calendar.date(byAdding: .day, value: -6, to: today),
              let lastWeekStart = calendar.date(byAdding: .day, value: -13, to: today) else {
            return nil
        }

        let thisWeekEntries = entries.filter { entry in
            let entryDate = calendar.startOfDay(for: entry.timestamp)
            return entryDate >= thisWeekStart && entryDate <= today
        }

        let lastWeekEntries = entries.filter { entry in
            let entryDate = calendar.startOfDay(for: entry.timestamp)
            return entryDate >= lastWeekStart && entryDate < thisWeekStart
        }

        let thisWeekDays = Set(thisWeekEntries.map { $0.dayIdentifier })
        let lastWeekDays = Set(lastWeekEntries.map { $0.dayIdentifier })

        guard thisWeekDays.count >= 3, lastWeekDays.count >= 3 else {
            return nil
        }

        let thisWeekAvg = thisWeekEntries.reduce(0) { $0 + $1.grams } / Double(thisWeekDays.count)
        let lastWeekAvg = lastWeekEntries.reduce(0) { $0 + $1.grams } / Double(lastWeekDays.count)

        let difference = lastWeekAvg - thisWeekAvg

        if abs(difference) >= 3 {
            if difference > 0 {
                return DailyInsight(
                    message: "This week you're averaging \(Int(thisWeekAvg))g - \(Int(difference))g better than last week!",
                    icon: "arrow.down.circle.fill",
                    type: .weeklyComparison
                )
            } else {
                return DailyInsight(
                    message: "This week's average is \(Int(thisWeekAvg))g - \(Int(abs(difference)))g higher than last week",
                    icon: "arrow.up.circle",
                    type: .weeklyComparison
                )
            }
        }

        return nil
    }

    // MARK: - Pace Projection

    private static func paceProjectionInsight(
        entries: [SugarEntry],
        currentTotal: Double,
        dailyGoal: Double
    ) -> DailyInsight? {
        let calendar = Calendar.current
        let now = Date()
        let todayId = SugarEntry.dayIdentifier(for: now)

        let todayEntries = entries.filter { $0.dayIdentifier == todayId }

        guard todayEntries.count >= 2 else {
            return nil
        }

        // Calculate hours elapsed today
        let startOfDay = calendar.startOfDay(for: now)
        let hoursElapsed = calendar.dateComponents([.hour], from: startOfDay, to: now).hour ?? 0

        guard hoursElapsed >= 8, hoursElapsed < 22 else {
            return nil // Only show projection during active hours
        }

        // Project based on current rate
        let hoursRemaining = min(16, 24 - hoursElapsed) // Assume active until ~10 PM
        let hourlyRate = currentTotal / Double(max(1, hoursElapsed - 6)) // Assume starts around 6 AM
        let projectedTotal = currentTotal + (hourlyRate * Double(hoursRemaining) * 0.5) // Reduced rate for remaining hours

        let projectedInt = Int(projectedTotal)

        if projectedTotal > dailyGoal && currentTotal <= dailyGoal {
            return DailyInsight(
                message: "At this pace, you might hit ~\(projectedInt)g by end of day",
                icon: "exclamationmark.triangle",
                type: .paceProjection
            )
        } else if projectedTotal <= dailyGoal * 0.8 {
            return DailyInsight(
                message: "Great pace! You're on track to stay well under your \(Int(dailyGoal))g goal",
                icon: "checkmark.circle.fill",
                type: .paceProjection
            )
        }

        return nil
    }

    // MARK: - Time of Day Pattern

    private static func timeOfDayInsight(entries: [SugarEntry], dailyGoal: Double) -> DailyInsight? {
        let calendar = Calendar.current

        var periodTotals: [String: (grams: Double, count: Int)] = [
            "morning": (0, 0),
            "afternoon": (0, 0),
            "evening": (0, 0)
        ]

        for entry in entries {
            let hour = calendar.component(.hour, from: entry.timestamp)
            let period: String

            if hour >= 6 && hour < 12 {
                period = "morning"
            } else if hour >= 12 && hour < 18 {
                period = "afternoon"
            } else if hour >= 18 && hour < 24 {
                period = "evening"
            } else {
                continue // Skip night entries for this insight
            }

            periodTotals[period]?.grams += entry.grams
            periodTotals[period]?.count += 1
        }

        // Need enough entries in each period
        let validPeriods = periodTotals.filter { $0.value.count >= 3 }
        guard validPeriods.count >= 2 else { return nil }

        let periodAverages = validPeriods.mapValues { $0.grams / Double($0.count) }

        if let maxPeriod = periodAverages.max(by: { $0.value < $1.value }),
           let minPeriod = periodAverages.min(by: { $0.value < $1.value }),
           maxPeriod.value - minPeriod.value >= 3 {

            let periodName = maxPeriod.key.capitalized
            return DailyInsight(
                message: "\(periodName) is your peak sugar time at \(Int(maxPeriod.value))g average",
                icon: "clock.fill",
                type: .timeOfDayPattern
            )
        }

        return nil
    }

    // MARK: - Weekday vs Weekend

    private static func weekdayVsWeekendInsight(entries: [SugarEntry], dailyGoal: Double) -> DailyInsight? {
        let calendar = Calendar.current

        var weekdayTotals: [String: Double] = [:]
        var weekendTotals: [String: Double] = [:]

        for entry in entries {
            let weekday = calendar.component(.weekday, from: entry.timestamp)
            let dayId = entry.dayIdentifier

            if weekday >= 2 && weekday <= 6 {
                weekdayTotals[dayId, default: 0] += entry.grams
            } else {
                weekendTotals[dayId, default: 0] += entry.grams
            }
        }

        guard weekdayTotals.count >= 3, weekendTotals.count >= 2 else {
            return nil
        }

        let weekdayAvg = weekdayTotals.values.reduce(0, +) / Double(weekdayTotals.count)
        let weekendAvg = weekendTotals.values.reduce(0, +) / Double(weekendTotals.count)

        let difference = weekendAvg - weekdayAvg

        if abs(difference) >= 5 {
            if difference > 0 {
                return DailyInsight(
                    message: "Your weekend average is \(Int(difference))g higher than weekdays",
                    icon: "calendar.badge.exclamationmark",
                    type: .weekdayVsWeekend
                )
            } else {
                return DailyInsight(
                    message: "You consume \(Int(abs(difference)))g less sugar on weekends",
                    icon: "hand.thumbsup.fill",
                    type: .weekdayVsWeekend
                )
            }
        }

        return nil
    }

    // MARK: - Streak Progress

    private static func streakInsight(entries: [SugarEntry], dailyGoal: Double) -> DailyInsight? {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Check yesterday and backwards
        checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!

        while true {
            let dayId = SugarEntry.dayIdentifier(for: checkDate)
            let dayTotal = entries.filter { $0.dayIdentifier == dayId }.reduce(0) { $0 + $1.grams }

            if dayTotal > 0 && dayTotal <= dailyGoal {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        if streak >= 3 && streak < 7 {
            return DailyInsight(
                message: "You're on a \(streak)-day streak! Keep it going for 7 days",
                icon: "flame.fill",
                type: .streakProgress
            )
        } else if streak >= 7 && streak < 14 {
            return DailyInsight(
                message: "Amazing \(streak)-day streak! Push for 14 days",
                icon: "bolt.fill",
                type: .streakProgress
            )
        }

        return nil
    }

    // MARK: - Time of Day Breakdown (for TimeOfDayCard)

    struct TimeBreakdown {
        let morning: Double  // 6 AM - 12 PM
        let afternoon: Double // 12 PM - 6 PM
        let evening: Double  // 6 PM - 12 AM
        let night: Double    // 12 AM - 6 AM

        var peakPeriod: String {
            let periods = [
                ("Morning", morning),
                ("Afternoon", afternoon),
                ("Evening", evening),
                ("Night", night)
            ]
            return periods.max(by: { $0.1 < $1.1 })?.0 ?? "Morning"
        }

        var total: Double {
            morning + afternoon + evening + night
        }

        func percentage(for period: String) -> Double {
            guard total > 0 else { return 0 }
            switch period.lowercased() {
            case "morning": return (morning / total) * 100
            case "afternoon": return (afternoon / total) * 100
            case "evening": return (evening / total) * 100
            case "night": return (night / total) * 100
            default: return 0
            }
        }
    }

    static func calculateTimeBreakdown(entries: [SugarEntry]) -> TimeBreakdown {
        let calendar = Calendar.current

        var morning: Double = 0
        var afternoon: Double = 0
        var evening: Double = 0
        var night: Double = 0

        var morningDays = Set<String>()
        var afternoonDays = Set<String>()
        var eveningDays = Set<String>()
        var nightDays = Set<String>()

        for entry in entries {
            let hour = calendar.component(.hour, from: entry.timestamp)
            let dayId = entry.dayIdentifier

            if hour >= 6 && hour < 12 {
                morning += entry.grams
                morningDays.insert(dayId)
            } else if hour >= 12 && hour < 18 {
                afternoon += entry.grams
                afternoonDays.insert(dayId)
            } else if hour >= 18 && hour < 24 {
                evening += entry.grams
                eveningDays.insert(dayId)
            } else {
                night += entry.grams
                nightDays.insert(dayId)
            }
        }

        // Calculate averages per day for each period
        let morningAvg = morningDays.isEmpty ? 0 : morning / Double(morningDays.count)
        let afternoonAvg = afternoonDays.isEmpty ? 0 : afternoon / Double(afternoonDays.count)
        let eveningAvg = eveningDays.isEmpty ? 0 : evening / Double(eveningDays.count)
        let nightAvg = nightDays.isEmpty ? 0 : night / Double(nightDays.count)

        return TimeBreakdown(
            morning: morningAvg,
            afternoon: afternoonAvg,
            evening: eveningAvg,
            night: nightAvg
        )
    }

    // MARK: - Weekly Trend Data

    struct WeeklyTrend {
        let thisWeekAverage: Double
        let lastWeekAverage: Double
        let thisWeekDaysTracked: Int
        let lastWeekDaysTracked: Int

        var difference: Double {
            lastWeekAverage - thisWeekAverage
        }

        var isImproving: Bool {
            difference > 0
        }

        var percentChange: Double {
            guard lastWeekAverage > 0 else { return 0 }
            return (difference / lastWeekAverage) * 100
        }

        var hasEnoughData: Bool {
            thisWeekDaysTracked >= 2 && lastWeekDaysTracked >= 2
        }
    }

    static func calculateWeeklyTrend(entries: [SugarEntry]) -> WeeklyTrend {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let thisWeekStart = calendar.date(byAdding: .day, value: -6, to: today),
              let lastWeekStart = calendar.date(byAdding: .day, value: -13, to: today) else {
            return WeeklyTrend(thisWeekAverage: 0, lastWeekAverage: 0, thisWeekDaysTracked: 0, lastWeekDaysTracked: 0)
        }

        var thisWeekTotals: [String: Double] = [:]
        var lastWeekTotals: [String: Double] = [:]

        for entry in entries {
            let entryDate = calendar.startOfDay(for: entry.timestamp)
            let dayId = entry.dayIdentifier

            if entryDate >= thisWeekStart && entryDate <= today {
                thisWeekTotals[dayId, default: 0] += entry.grams
            } else if entryDate >= lastWeekStart && entryDate < thisWeekStart {
                lastWeekTotals[dayId, default: 0] += entry.grams
            }
        }

        let thisWeekAvg = thisWeekTotals.isEmpty ? 0 : thisWeekTotals.values.reduce(0, +) / Double(thisWeekTotals.count)
        let lastWeekAvg = lastWeekTotals.isEmpty ? 0 : lastWeekTotals.values.reduce(0, +) / Double(lastWeekTotals.count)

        return WeeklyTrend(
            thisWeekAverage: thisWeekAvg,
            lastWeekAverage: lastWeekAvg,
            thisWeekDaysTracked: thisWeekTotals.count,
            lastWeekDaysTracked: lastWeekTotals.count
        )
    }
}
