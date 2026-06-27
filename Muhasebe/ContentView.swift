import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    @StateObject private var state = AppState()

    init() {
        #if canImport(UIKit)

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.white

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.primary)]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Theme.secondaryText.opacity(0.5))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.secondaryText.opacity(0.5))]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("The Hub", systemImage: "square.grid.2x2.fill")
                }

            TransactionsView()
                .tabItem {
                    Label("Ledger", systemImage: "list.bullet.rectangle.portrait.fill")
                }

            AnalyticsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.xyaxis.line")
                }

            VaultView()
                .tabItem {
                    Label("The Vault", systemImage: "lock.shield.fill")
                }
        }
        .environmentObject(state)
        .accentColor(Theme.primary)
    }
}

#Preview {
    ContentView()
}
