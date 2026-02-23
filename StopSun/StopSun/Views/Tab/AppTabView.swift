//
//  AppTabView.swift
//  StopSun
//
//  Created by J on 2/23/26.
//

import SwiftUI

struct AppTabView: View {
    
    @State private var selectedTab: AppTab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - 대시보드
            
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                tabLabel(for: .dashboard)
            }
            .tag(AppTab.dashboard)
            
            // MARK: - 기록
            
            NavigationStack {
                RecordsPlaceholderView()
            }
            .tabItem {
                tabLabel(for: .records)
            }
            .tag(AppTab.records)
            
            // MARK: - 설정
            
            NavigationStack {
                SettingsPlaceholderView()
            }
            .tabItem {
                tabLabel(for: .settings)
            }
            .tag(AppTab.settings)
        }
         .tint(.text00)
    }
    
    // MARK: - Tab Label
    
    @ViewBuilder
    private func tabLabel(for tab: AppTab) -> some View {
        let icon = selectedTab == tab ? tab.selectedIconName : tab.iconName
        Image(icon)
        Text(tab.title)
    }
}

// MARK: - Placeholder Views

/// 기록 탭 placeholder (추후 실제 화면으로 교체)
struct RecordsPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.white01.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.text04)
                
                Text("기록")
                    .font(.ssFont(.SB4))
                    .foregroundStyle(.text00)
                
                Text("UV 노출 기록이 여기에 표시됩니다")
                    .font(.ssFont(.R3))
                    .foregroundStyle(.text04)
            }
        }
    }
}

/// 설정 탭 placeholder (추후 실제 화면으로 교체)
struct SettingsPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.white01.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Image(systemName: "gearshape")
                    .font(.system(size: 48))
                    .foregroundStyle(.text04)
                
                Text("설정")
                    .font(.ssFont(.SB4))
                    .foregroundStyle(.text00)
                
                Text("앱 설정이 여기에 표시됩니다")
                    .font(.ssFont(.R3))
                    .foregroundStyle(.text04)
            }
        }
    }
}

#Preview {
    AppTabView()
}
