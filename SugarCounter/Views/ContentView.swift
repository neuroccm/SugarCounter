import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DailyView()
                .tabItem {
                    Label("Today", systemImage: "cube.fill")
                }

            ChartView()
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.fill")
                }

            CalendarView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SugarEntry.self, inMemory: true)
}
