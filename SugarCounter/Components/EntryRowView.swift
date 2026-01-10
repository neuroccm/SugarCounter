import SwiftUI

struct EntryRowView: View {
    let entry: SugarEntry

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.headline)
                Text(timeFormatter.string(from: entry.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(entry.grams, specifier: "%.1f")g")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        EntryRowView(entry: SugarEntry(grams: 12.5, itemNumber: 1))
        EntryRowView(entry: SugarEntry(grams: 8.0, itemNumber: 2))
        EntryRowView(entry: SugarEntry(grams: 15.5, itemNumber: 3))
    }
}
