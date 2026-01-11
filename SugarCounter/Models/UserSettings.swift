import Foundation
import SwiftData

enum GoalPreset: String, CaseIterable, Codable {
    case whoRecommended = "WHO Recommended"
    case ahaWomen = "AHA Women"
    case ahaMen = "AHA Men"
    case lowSugar = "Low Sugar"
    case custom = "Custom"

    var dailyGoal: Double {
        switch self {
        case .whoRecommended: return 25.0
        case .ahaWomen: return 25.0
        case .ahaMen: return 36.0
        case .lowSugar: return 15.0
        case .custom: return 30.0
        }
    }

    var cautionThreshold: Double {
        switch self {
        case .whoRecommended: return 15.0
        case .ahaWomen: return 15.0
        case .ahaMen: return 24.0
        case .lowSugar: return 10.0
        case .custom: return 20.0
        }
    }

    var description: String {
        switch self {
        case .whoRecommended:
            return "World Health Organization recommendation for adults"
        case .ahaWomen:
            return "American Heart Association limit for women"
        case .ahaMen:
            return "American Heart Association limit for men"
        case .lowSugar:
            return "Strict low-sugar lifestyle goal"
        case .custom:
            return "Set your own daily goal"
        }
    }
}

@Model
final class UserSettings {
    var id: UUID
    var dailyGoal: Double
    var cautionThreshold: Double
    var selectedPreset: String
    var streakStartDate: Date?
    var longestStreak: Int
    var totalDaysTracked: Int
    var achievementsUnlocked: [String]

    init() {
        self.id = UUID()
        self.dailyGoal = 25.0
        self.cautionThreshold = 15.0
        self.selectedPreset = GoalPreset.whoRecommended.rawValue
        self.streakStartDate = nil
        self.longestStreak = 0
        self.totalDaysTracked = 0
        self.achievementsUnlocked = []
    }

    var preset: GoalPreset {
        get { GoalPreset(rawValue: selectedPreset) ?? .whoRecommended }
        set { selectedPreset = newValue.rawValue }
    }

    func applyPreset(_ preset: GoalPreset) {
        self.selectedPreset = preset.rawValue
        if preset != .custom {
            self.dailyGoal = preset.dailyGoal
            self.cautionThreshold = preset.cautionThreshold
        }
    }
}
