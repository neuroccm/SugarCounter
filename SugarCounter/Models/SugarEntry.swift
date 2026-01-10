import Foundation
import SwiftData

@Model
final class SugarEntry {
    var id: UUID
    var grams: Double
    var itemNumber: Int
    var timestamp: Date
    var dayIdentifier: String
    var customName: String?

    var displayName: String {
        customName ?? "Item \(itemNumber)"
    }

    init(grams: Double, itemNumber: Int, date: Date = Date()) {
        self.id = UUID()
        self.grams = grams
        self.itemNumber = itemNumber
        self.timestamp = date
        self.dayIdentifier = Self.dayIdentifier(for: date)
        self.customName = nil
    }

    static func dayIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func todayIdentifier() -> String {
        dayIdentifier(for: Date())
    }
}
