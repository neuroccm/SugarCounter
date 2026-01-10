import SwiftUI

struct EntryKeypadView: View {
    let itemNumber: Int
    let onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var inputString = ""

    private var displayValue: String {
        if inputString.isEmpty {
            return "0"
        }
        return inputString
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
                    Text("Item \(itemNumber)")
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
                                KeypadButton(key: key) {
                                    handleKeyPress(key)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Button {
                    onSave(numericValue)
                    dismiss()
                } label: {
                    Text("Add")
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
            .navigationTitle("Add Sugar")
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

struct KeypadButton: View {
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
    EntryKeypadView(itemNumber: 1) { grams in
        print("Saved: \(grams)g")
    }
}
