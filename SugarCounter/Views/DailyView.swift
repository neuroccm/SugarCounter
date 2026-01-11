import SwiftUI
import SwiftData

struct DailyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [SugarEntry]
    @Query private var allSettings: [UserSettings]
    @State private var showingKeypad = false
    @State private var entryToRename: SugarEntry?
    @State private var renameText = ""
    @State private var entryToEditGrams: SugarEntry?
    @State private var currentDate = Date()
    @State private var showingAbout = false
    @State private var showingGoalSettings = false

    private let calendar = Calendar.current

    private var settings: UserSettings? {
        allSettings.first
    }

    private var dailyGoal: Double {
        settings?.dailyGoal ?? SugarConstants.defaultDailyGoal
    }

    private var cautionThreshold: Double {
        settings?.cautionThreshold ?? SugarConstants.defaultCautionThreshold
    }

    private var dayId: String {
        SugarEntry.dayIdentifier(for: currentDate)
    }

    private var currentEntries: [SugarEntry] {
        allEntries
            .filter { $0.dayIdentifier == dayId }
            .sorted { $0.itemNumber < $1.itemNumber }
    }

    private var currentTotal: Double {
        currentEntries.reduce(0) { $0 + $1.grams }
    }

    private var nextItemNumber: Int {
        (currentEntries.map(\.itemNumber).max() ?? 0) + 1
    }

    private var isToday: Bool {
        calendar.isDateInToday(currentDate)
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

    private var emptyStateMessage: String {
        isToday ? "No entries yet today" : "No entries for this day"
    }

    var body: some View {
        NavigationStack {
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

                    VStack(spacing: 2) {
                        Text(dateTitle)
                            .font(.headline)
                        if !isToday {
                            Button("Back to Today") {
                                withAnimation {
                                    currentDate = Date()
                                }
                            }
                            .font(.caption)
                        }
                    }

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
                    .disabled(isToday)
                    .opacity(isToday ? 0.3 : 1)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ProgressRingView(
                    total: currentTotal,
                    goal: dailyGoal,
                    cautionThreshold: cautionThreshold,
                    lineWidth: 24
                )
                .frame(width: 200, height: 200)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .onTapGesture {
                    showingGoalSettings = true
                }

                if currentEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle.dashed")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        Text(emptyStateMessage)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap to add sugar intake")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingKeypad = true
                    }
                } else {
                    List {
                        ForEach(currentEntries) { entry in
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
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingGoalSettings) {
                GoalSettingsView()
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
            modelContext.delete(currentEntries[index])
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct RenameEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: SugarEntry
    @State private var name: String

    init(entry: SugarEntry, initialName: String) {
        self.entry = entry
        self._name = State(initialValue: initialName)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .padding(.horizontal)

                Text("Leave empty to use \"Item \(entry.itemNumber)\"")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Rename Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        entry.customName = name.isEmpty ? nil : name
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditGramsView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: SugarEntry
    @State private var inputString: String

    init(entry: SugarEntry) {
        self.entry = entry
        let formatted = entry.grams.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", entry.grams)
            : String(format: "%.1f", entry.grams)
        self._inputString = State(initialValue: formatted)
    }

    private var displayValue: String {
        inputString.isEmpty ? "0" : inputString
    }

    private var numericValue: Double {
        Double(inputString) ?? 0
    }

    private var isValidInput: Bool {
        numericValue > 0
    }

    private let keypadButtons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(entry.displayName)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(displayValue)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.1), value: inputString)
                        Text("g")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 16)

                VStack(spacing: 12) {
                    ForEach(keypadButtons, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { key in
                                EditGramsKeypadButton(key: key) {
                                    handleKeyPress(key)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Button {
                    entry.grams = numericValue
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValidInput ? Color.accentColor : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isValidInput)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .navigationTitle("Edit Grams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func handleKeyPress(_ key: String) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        switch key {
        case "⌫":
            if !inputString.isEmpty {
                inputString.removeLast()
            }
        case ".":
            if !inputString.contains(".") {
                if inputString.isEmpty {
                    inputString = "0."
                } else {
                    inputString += "."
                }
            }
        default:
            if inputString.contains(".") {
                let parts = inputString.split(separator: ".", omittingEmptySubsequences: false)
                if parts.count > 1 && parts[1].count >= 1 {
                    return
                }
            }
            if inputString == "0" && key != "." {
                inputString = key
            } else if inputString.count < 5 {
                inputString += key
            }
        }
    }
}

struct EditGramsKeypadButton: View {
    let key: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if key == "⌫" {
                    Image(systemName: "delete.left")
                        .font(.title2)
                } else {
                    Text(key)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DailyView()
        .modelContainer(for: [SugarEntry.self, UserSettings.self], inMemory: true)
}
