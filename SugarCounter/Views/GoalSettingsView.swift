import SwiftUI
import SwiftData

struct GoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]

    @State private var selectedPreset: GoalPreset = .whoRecommended
    @State private var customGoal: Double = 30.0
    @State private var customCaution: Double = 20.0

    private var settings: UserSettings {
        if let existing = allSettings.first {
            return existing
        }
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        return newSettings
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(GoalPreset.allCases, id: \.self) { preset in
                        PresetRow(
                            preset: preset,
                            isSelected: selectedPreset == preset,
                            onSelect: {
                                selectedPreset = preset
                                if preset != .custom {
                                    customGoal = preset.dailyGoal
                                    customCaution = preset.cautionThreshold
                                }
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        )
                    }
                } header: {
                    Text("Goal Presets")
                } footer: {
                    Text("Choose a preset or customize your own daily sugar goal.")
                }

                if selectedPreset == .custom {
                    Section("Custom Goal") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily Limit: \(Int(customGoal))g")
                                .font(.headline)
                            Slider(value: $customGoal, in: 10...100, step: 1)
                                .tint(.red)
                        }
                        .padding(.vertical, 4)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Caution at: \(Int(customCaution))g")
                                .font(.headline)
                            Slider(value: $customCaution, in: 5...customGoal - 5, step: 1)
                                .tint(.yellow)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            GoalPreviewBadge(
                                label: "Good",
                                range: "0-\(Int(customCaution))g",
                                color: .green
                            )
                            GoalPreviewBadge(
                                label: "Caution",
                                range: "\(Int(customCaution)+1)-\(Int(customGoal))g",
                                color: .yellow
                            )
                            GoalPreviewBadge(
                                label: "Over",
                                range: ">\(Int(customGoal))g",
                                color: .red
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Set Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }

    private func loadCurrentSettings() {
        if let existing = allSettings.first {
            selectedPreset = existing.preset
            customGoal = existing.dailyGoal
            customCaution = existing.cautionThreshold
        }
    }

    private func saveSettings() {
        let settingsToUpdate: UserSettings
        if let existing = allSettings.first {
            settingsToUpdate = existing
        } else {
            settingsToUpdate = UserSettings()
            modelContext.insert(settingsToUpdate)
        }

        settingsToUpdate.applyPreset(selectedPreset)
        if selectedPreset == .custom {
            settingsToUpdate.dailyGoal = customGoal
            settingsToUpdate.cautionThreshold = customCaution
        }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct PresetRow: View {
    let preset: GoalPreset
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(preset.description)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if preset != .custom {
                        Text("Goal: \(Int(preset.dailyGoal))g • Caution: \(Int(preset.cautionThreshold))g")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct GoalPreviewBadge: View {
    let label: String
    let range: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)

            Text(label)
                .font(.caption)
                .fontWeight(.medium)

            Text(range)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GoalSettingsView()
        .modelContainer(for: [UserSettings.self, SugarEntry.self], inMemory: true)
}
