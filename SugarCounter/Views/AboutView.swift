import SwiftUI
import SwiftData
import MessageUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SugarEntry.timestamp) private var allEntries: [SugarEntry]
    @State private var showingMailComposer = false
    @State private var showingShareSheet = false
    @State private var csvURL: URL?
    @State private var showingExportError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Title
                    VStack(spacing: 12) {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.linearGradient(
                                colors: [.green, .yellow, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        Text("Sugar Counter")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Export Button
                    Button {
                        exportData()
                    } label: {
                        Label("Export Data as CSV", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // About Content
                    VStack(alignment: .leading, spacing: 20) {
                        AboutSection(title: "The Vision", content: """
As a physician and researcher, I have spent my career witnessing the profound impact of lifestyle on neurological and systemic health. We are currently facing a global metabolic crisis, driven in large part by a substance that is as ubiquitous as it is misunderstood: refined sugar.

Inspired by the pioneering work of experts like Dr. Robert Lustig ("The Bitter Truth"), I developed Sugar Counter. My goal was simple: to move beyond "calorie counting" and provide a precision tool that addresses the specific metabolic burden of added and refined sugars.
""")

                        AboutSection(title: "The Science: Why Sugar Matters", content: """
The modern diet is saturated with "hidden" sugars—specifically high-fructose corn syrup and sucrose—that bypass normal satiety signals and place an immense metabolic load on the liver. Unlike glucose, which can be used by every cell in the body, fructose is primarily processed in the liver, where in high doses it can trigger lipogenesis (fat production), insulin resistance, and chronic inflammation.

Research highlights the urgency of this intervention:

• Metabolic Syndrome: Excessive refined sugar intake is a primary driver of metabolic syndrome, independent of total caloric intake (Lustig et al., 2012, Nature).

• Cardiovascular Risk: High-sugar diets are significantly associated with increased risk of cardiovascular disease mortality (Yang et al., 2014, JAMA Internal Medicine).

• The 5% Rule: The World Health Organization (WHO) strongly recommends reducing the intake of free sugars to less than 10%—and ideally 5%—of total energy intake to prevent non-communicable diseases (WHO Guideline, 2015).

Sugar Counter is designed to help you stay within these evidence-based limits, providing clarity in an era of nutritional noise.
""")

                        AboutSection(title: "About the Developer", content: """
Houman Khosravani, MD PhD FRCPC

Dr. Khosravani is a physician-specialist and clinician-scientist. With a background in complex systems and medicine, he bridges the gap between high-level clinical research and practical, patient-facing technology. Sugar Counter is born from his commitment to preventative health and the belief that data-driven transparency is the first step toward metabolic recovery.
""")

                        AboutSection(title: "Disclaimer", content: """
No Duty of Care or Medical Advice

The information provided by the Sugar Counter app and within this documentation is for educational and informational purposes only. It is not intended to be a substitute for professional medical advice, diagnosis, or treatment.

Use of this app does not establish a doctor-patient relationship between you and Dr. Houman Khosravani. Dr. Khosravani owes no duty of care to users of this application. Always seek the advice of your physician or another qualified health provider with any questions you may have regarding a medical condition or nutritional changes. Never disregard professional medical advice or delay in seeking it because of something you have read or tracked within this app. Reliance on any information provided by the app is solely at your own risk.
""")
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = csvURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Export Error", isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Unable to create export file. Please try again.")
            }
        }
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
        var csvContent = "Date,Total Refined Sugar (g)\n"

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"

        for dayId in sortedDays {
            if let date = inputFormatter.date(from: dayId) {
                let formattedDate = outputFormatter.string(from: date)
                let total = dailyTotals[dayId] ?? 0
                csvContent += "\(formattedDate),\(String(format: "%.1f", total))\n"
            }
        }

        // Save to temp file
        let fileName = "SugarCounter_Export_\(outputFormatter.string(from: Date()).replacingOccurrences(of: "/", with: "-")).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            csvURL = tempURL
            showingShareSheet = true
        } catch {
            showingExportError = true
        }
    }
}

struct AboutSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AboutView()
        .modelContainer(for: SugarEntry.self, inMemory: true)
}
