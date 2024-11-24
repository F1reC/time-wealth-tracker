//
//  ContentView.swift
//  time-wealth-tracker
//
//  Created by F1reC on 25/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = TimeWealthStore()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(store)
                .tabItem {
                    Label("概览", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            TimeTrackingView()
                .environmentObject(store)
                .tabItem {
                    Label("记录", systemImage: "clock.fill")
                }
                .tag(1)
            
            BudgetView()
                .environmentObject(store)
                .tabItem {
                    Label("预算", systemImage: "dollarsign.circle.fill")
                }
                .tag(2)
            
            HistoryView()
                .environmentObject(store)
                .tabItem {
                    Label("历史", systemImage: "calendar")
                }
                .tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
