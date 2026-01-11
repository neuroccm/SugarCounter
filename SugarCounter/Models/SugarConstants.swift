import SwiftUI

enum SugarConstants {
    // Default values (used when no UserSettings exist)
    static let defaultDailyGoal: Double = 25.0
    static let defaultCautionThreshold: Double = 15.0

    // Legacy static accessors for backward compatibility
    static var dailyGoal: Double {
        defaultDailyGoal
    }

    static var cautionThreshold: Double {
        defaultCautionThreshold
    }

    static func statusColor(for grams: Double, goal: Double? = nil, cautionThreshold: Double? = nil) -> Color {
        let effectiveGoal = goal ?? defaultDailyGoal
        let effectiveCaution = cautionThreshold ?? defaultCautionThreshold

        if grams <= effectiveCaution {
            return .green
        } else if grams <= effectiveGoal {
            return .yellow
        } else {
            return .red
        }
    }

    static func statusLabel(for grams: Double, goal: Double? = nil, cautionThreshold: Double? = nil) -> String {
        let effectiveGoal = goal ?? defaultDailyGoal
        let effectiveCaution = cautionThreshold ?? defaultCautionThreshold

        if grams <= effectiveCaution {
            return "Good"
        } else if grams <= effectiveGoal {
            return "Caution"
        } else {
            return "Over Limit"
        }
    }
}
