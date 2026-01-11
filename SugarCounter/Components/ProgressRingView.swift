import SwiftUI

struct ProgressRingView: View {
    let total: Double
    let goal: Double
    var cautionThreshold: Double?
    let lineWidth: CGFloat

    private var effectiveCautionThreshold: Double {
        cautionThreshold ?? (goal * 0.67)
    }

    private var progress: Double {
        min(total / goal, 1.5)
    }

    private var color: Color {
        SugarConstants.statusColor(for: total, goal: goal, cautionThreshold: effectiveCautionThreshold)
    }

    private var statusLabel: String {
        SugarConstants.statusLabel(for: total, goal: goal, cautionThreshold: effectiveCautionThreshold)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            if total > goal {
                Circle()
                    .trim(from: 0, to: progress - 1.0)
                    .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }

            VStack(spacing: 4) {
                Text("\(Int(round(total)))g")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: total)

                Text("of \(Int(goal))g")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(statusLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgressRingView(total: 15, goal: 30, lineWidth: 20)
            .frame(width: 200, height: 200)
        ProgressRingView(total: 25, goal: 30, lineWidth: 20)
            .frame(width: 200, height: 200)
        ProgressRingView(total: 45, goal: 30, lineWidth: 20)
            .frame(width: 200, height: 200)
    }
    .padding()
}
