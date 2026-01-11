import SwiftUI
import SwiftData

struct SelectedDateItem: Identifiable {
    let id = UUID()
    let date: Date
}

struct CalendarView: View {
    @Query private var allEntries: [SugarEntry]
    @Query private var allSettings: [UserSettings]
    @State private var displayedMonth: Date = Date()
    @State private var selectedDateItem: SelectedDateItem?
    @State private var showingAbout = false
    @State private var exportItem: ExportItem?
    @State private var showingExportError = false

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    private var settings: UserSettings? {
        allSettings.first
    }

    private var dailyGoal: Double {
        settings?.dailyGoal ?? SugarConstants.defaultDailyGoal
    }

    private var cautionThreshold: Double {
        settings?.cautionThreshold ?? SugarConstants.defaultCautionThreshold
    }

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
                            let isFutureDate = date > calendar.startOfDay(for: Date())
                            CalendarDayCell(
                                date: date,
                                total: totalForDate(date),
                                isToday: calendar.isDateInToday(date),
                                isFuture: isFutureDate,
                                goal: dailyGoal,
                                cautionThreshold: cautionThreshold
                            )
                            .onTapGesture {
                                if !isFutureDate {
                                    selectedDateItem = SelectedDateItem(date: date)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button {
                            exportData()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                        }
                        Button("Today") {
                            withAnimation {
                                displayedMonth = Date()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(item: $exportItem) { item in
                ShareSheet(items: [item.content, item.url])
            }
            .alert("Export Error", isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Unable to create export file. Please try again.")
            }
            .sheet(item: $selectedDateItem) { item in
                DayDetailView(
                    date: item.date,
                    dailyGoal: dailyGoal,
                    cautionThreshold: cautionThreshold
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var legendView: some View {
        HStack(spacing: 20) {
            LegendItem(color: .green, label: "Good (≤\(Int(cautionThreshold))g)")
            LegendItem(color: .yellow, label: "Caution")
            LegendItem(color: .red, label: "Over (>\(Int(dailyGoal))g)")
        }
        .font(.caption)
    }

    private func exportData() {
        // Group entries by day and calculate totals
        var dailyTotals: [String: Double] = [:]

        for entry in allEntries {
            dailyTotals[entry.dayIdentifier, default: 0] += entry.grams
        }

        // Sort by date
        let sortedDays = dailyTotals.keys.sorted()

        // Create CSV content
        var content = "Date,Total Refined Sugar (g)\n"

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"

        for dayId in sortedDays {
            if let date = inputFormatter.date(from: dayId) {
                let formattedDate = outputFormatter.string(from: date)
                let total = dailyTotals[dayId] ?? 0
                content += "\(formattedDate),\(String(format: "%.1f", total))\n"
            }
        }

        // Save to temp file
        let fileName = "SugarCounter_Export_\(outputFormatter.string(from: Date()).replacingOccurrences(of: "/", with: "-")).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            exportItem = ExportItem(url: tempURL, content: content)
        } catch {
            showingExportError = true
        }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let total: Double
    let isToday: Bool
    let isFuture: Bool
    let goal: Double
    let cautionThreshold: Double

    private let calendar = Calendar.current

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var hasData: Bool {
        total > 0
    }

    private var dotColor: Color {
        hasData ? SugarConstants.statusColor(for: total, goal: goal, cautionThreshold: cautionThreshold) : .clear
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : (isFuture ? .secondary.opacity(0.5) : .primary))
                .frame(width: 32, height: 32)
                .background(isToday ? Color.accentColor : Color.clear)
                .clipShape(Circle())

            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
        }
        .frame(height: 50)
        .opacity(isFuture ? 0.4 : 1.0)
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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [SugarEntry]

    @State var currentDate: Date
    let dailyGoal: Double
    let cautionThreshold: Double

    @State private var entryToRename: SugarEntry?
    @State private var renameText = ""
    @State private var entryToEditGrams: SugarEntry?
    @State private var showingKeypad = false

    private let calendar = Calendar.current

    init(date: Date, dailyGoal: Double, cautionThreshold: Double) {
        self._currentDate = State(initialValue: date)
        self.dailyGoal = dailyGoal
        self.cautionThreshold = cautionThreshold
    }

    private var dayId: String {
        SugarEntry.dayIdentifier(for: currentDate)
    }

    private var entries: [SugarEntry] {
        allEntries
            .filter { $0.dayIdentifier == dayId }
            .sorted { $0.itemNumber < $1.itemNumber }
    }

    private var total: Double {
        entries.reduce(0) { $0 + $1.grams }
    }

    private var nextItemNumber: Int {
        (entries.map(\.itemNumber).max() ?? 0) + 1
    }

    private var dateTitle: String {
        if calendar.isDateInToday(currentDate) {
            return "Today"
        } else if calendar.isDateInYesterday(currentDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: currentDate)
        }
    }

    private var statusColor: Color {
        SugarConstants.statusColor(for: total, goal: dailyGoal, cautionThreshold: cautionThreshold)
    }

    private var statusLabel: String {
        SugarConstants.statusLabel(for: total, goal: dailyGoal, cautionThreshold: cautionThreshold)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("No entries for this day")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap to add sugar intake")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            showingKeypad = true
        }
    }

    private var entriesListView: some View {
        List {
            ForEach(entries) { entry in
                EntryRowView(
                    entry: entry,
                    onRename: {
                        renameText = entry.customName ?? ""
                        entryToRename = entry
                    },
                    onEditGrams: {
                        entryToEditGrams = entry
                    }
                )
                .contextMenu {
                    Button {
                        renameText = entry.customName ?? ""
                        entryToRename = entry
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button {
                        entryToEditGrams = entry
                    } label: {
                        Label("Edit Grams", systemImage: "number")
                    }
                    Button(role: .destructive) {
                        modelContext.delete(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Date navigation header
            HStack {
                Button {
                    withAnimation {
                        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                Text(dateTitle)
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .disabled(calendar.isDateInToday(currentDate))
                .opacity(calendar.isDateInToday(currentDate) ? 0.3 : 1)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text("\(Int(round(total)))g")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)

                Text(statusLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Content area
            if entries.isEmpty {
                emptyStateView
            } else {
                entriesListView
            }
        }
    }

    var body: some View {
        NavigationStack {
            mainContent
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingKeypad = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingKeypad) {
                EntryKeypadView(
                    itemNumber: nextItemNumber,
                    onSave: { grams in
                        addEntry(grams: grams)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $entryToRename) { entry in
                RenameEntryView(
                    entry: entry,
                    initialName: renameText
                )
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $entryToEditGrams) { entry in
                EditGramsView(entry: entry)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func addEntry(grams: Double) {
        let entry = SugarEntry(grams: grams, itemNumber: nextItemNumber, date: currentDate)
        modelContext.insert(entry)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [SugarEntry.self, UserSettings.self], inMemory: true)
}
