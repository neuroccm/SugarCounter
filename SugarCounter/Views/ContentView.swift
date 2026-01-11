import SwiftUI

enum AppTab: Int, CaseIterable {
    case today = 0
    case insights = 1
    case charts = 2
    case history = 3
    case learn = 4
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyView()
                .tag(AppTab.today)
                .tabItem {
                    Label("Today", systemImage: "cube.fill")
                }

            InsightsView()
                .id("insights-\(selectedTab == .insights)")
                .tag(AppTab.insights)
                .tabItem {
                    Label("Insights", systemImage: "lightbulb.fill")
                }

            ChartView()
                .id("charts-\(selectedTab == .charts)")
                .tag(AppTab.charts)
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.fill")
                }

            CalendarView()
                .id("history-\(selectedTab == .history)")
                .tag(AppTab.history)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            LearnView()
                .tag(AppTab.learn)
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SugarEntry.self, UserSettings.self], inMemory: true)
}
