import SwiftUI
import SwiftData

struct DailyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [SugarEntry]
    @State private var showingKeypad = false
    @State private var entryToRename: SugarEntry?
    @State private var renameText = ""

    private var todayEntries: [SugarEntry] {
        let today = SugarEntry.todayIdentifier()
        return allEntries
            .filter { $0.dayIdentifier == today }
            .sorted { $0.itemNumber < $1.itemNumber }
    }

    private var todayTotal: Double {
        todayEntries.reduce(0) { $0 + $1.grams }
    }

    private var nextItemNumber: Int {
        (todayEntries.map(\.itemNumber).max() ?? 0) + 1
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressRingView(
                    total: todayTotal,
                    goal: SugarConstants.dailyGoal,
                    lineWidth: 24
                )
                .frame(width: 220, height: 220)
                .padding(.top, 20)
                .padding(.bottom, 24)

                if todayEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle.dashed")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No entries yet today")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap + to add sugar intake")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(todayEntries) { entry in
                            EntryRowView(entry: entry)
                                .contextMenu {
                                    Button {
                                        renameText = entry.customName ?? ""
                                        entryToRename = entry
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
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
            .navigationTitle("Today")
            .toolbar {
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
        }
    }

    private func addEntry(grams: Double) {
        let entry = SugarEntry(grams: grams, itemNumber: nextItemNumber)
        modelContext.insert(entry)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(todayEntries[index])
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

#Preview {
    DailyView()
        .modelContainer(for: SugarEntry.self, inMemory: true)
}
