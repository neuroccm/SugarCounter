import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var allEntries: [SugarEntry]
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var daysInMonth: [Date?] {
        let interval = calendar.dateInterval(of: .month, for: displayedMonth)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        var date = firstDay
        while date < interval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func totalForDate(_ date: Date) -> Double {
        let dayId = SugarEntry.dayIdentifier(for: date)
        return allEntries
            .filter { $0.dayIdentifier == dayId }
            .reduce(0) { $0 + $1.grams }
    }

    private func entriesForDate(_ date: Date) -> [SugarEntry] {
        let dayId = SugarEntry.dayIdentifier(for: date)
        return allEntries
            .filter { $0.dayIdentifier == dayId }
            .sorted { $0.itemNumber < $1.itemNumber }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Button {
                        withAnimation {
                            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    Text(monthTitle)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        withAnimation {
                            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal)

                HStack {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            CalendarDayCell(
                                date: date,
                                total: totalForDate(date),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                selectedDate = date
                                if totalForDate(date) > 0 {
                                    showingDayDetail = true
                                }
                            }
                        } else {
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                }
                .padding(.horizontal, 8)

                legendView
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Today") {
                        withAnimation {
                            displayedMonth = Date()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDayDetail) {
                if let date = selectedDate {
                    DayDetailView(date: date, entries: entriesForDate(date))
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }

    private var legendView: some View {
        HStack(spacing: 20) {
            LegendItem(color: .green, label: "Good (≤20g)")
            LegendItem(color: .yellow, label: "Caution")
            LegendItem(color: .red, label: "Over (>30g)")
        }
        .font(.caption)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let total: Double
    let isToday: Bool

    private let calendar = Calendar.current

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var hasData: Bool {
        total > 0
    }

    private var dotColor: Color {
        hasData ? SugarConstants.statusColor(for: total) : .clear
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(isToday ? Color.accentColor : Color.clear)
                .clipShape(Circle())

            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
        }
        .frame(height: 50)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

struct DayDetailView: View {
    let date: Date
    let entries: [SugarEntry]

    private var total: Double {
        entries.reduce(0) { $0 + $1.grams }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("\(Int(round(total)))g")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(SugarConstants.statusColor(for: total))

                    Text(SugarConstants.statusLabel(for: total))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                if entries.isEmpty {
                    Text("No entries for this day")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(entries) { entry in
                            EntryRowView(entry: entry)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: SugarEntry.self, inMemory: true)
}
