import SwiftUI

enum SugarConstants {
    static let dailyGoal: Double = 30.0
    static let cautionThreshold: Double = 20.0

    static func statusColor(for grams: Double) -> Color {
        if grams <= cautionThreshold {
            return .green
        } else if grams <= dailyGoal {
            return .yellow
        } else {
            return .red
        }
    }

    static func statusLabel(for grams: Double) -> String {
        if grams <= cautionThreshold {
            return "Good"
        } else if grams <= dailyGoal {
            return "Caution"
        } else {
            return "Over Limit"
        }
    }
}
