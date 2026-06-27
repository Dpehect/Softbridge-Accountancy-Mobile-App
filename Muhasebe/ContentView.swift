//
//  ContentView.swift
//  Muhasebe
//
//  Created by Yunus Emre Gürlek on 27.06.2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    @StateObject private var state = AppState()
    
    init() {
        #if canImport(UIKit)
        // Configure iOS tab bar appearance to align with Soft Bridge style
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.white
        
        // Active tab colors (Deep Teal)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.primary)]
        
        // Inactive tab colors (Muted Teal-Gray)
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
