//
//  DashboardView.swift
//  StopSun
//
//  Created by taeni on 9/16/25.
//

import SwiftUI

struct DashboardView: View {
    
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        ZStack {
            Color.white01.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                headerSection

                
                cardCarousel
                    .padding(.vertical, 32)
                
                pageIndicator
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 40)
                
                weatherSection
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.formattedDate)
                .font(.ssFont(.R3))
                .foregroundStyle(.text00)
            
            VStack(alignment: .leading, spacing: 4) {
                (
                    Text(L10n.MED.Status.prefix)
                        .foregroundStyle(.text00) +
                    Text(viewModel.warningLevel.levelName)
                        .foregroundStyle(viewModel.warningLevel.color) +
                    Text(L10n.MED.Status.suffix)
                        .foregroundStyle(viewModel.warningLevel.color)
                )
                .font(.ssFont(.SB4))
                
                Text(viewModel.warningLevel.statusDescription)
                    .font(.ssFont(.R5))
                    .foregroundStyle(.text04)
            }
        }
    }
    
    private var cardCarousel: some View {
        TabView(selection: $viewModel.currentPage) {
            DashboardMEDCardView(
                percentage: viewModel.medPercentage,
                currentValue: viewModel.currentSED,
                maxValue: viewModel.maxSED,
                color: viewModel.warningLevel.color
            )
            .padding(.horizontal, 20)
            .tag(0)
            
            SunscreenTimerCardView(
                remainingTime: viewModel.timerRemaining,
                isTimerActive: viewModel.isTimerActive
            )
            .padding(.horizontal, 20)
            .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 265)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white00)
        )
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPage ? Color.key00 : Color.gray00)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
            }
        }
    }
    
    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Dashboard.Weather.title(viewModel.locationName))
                .font(.ssFont(.M4))
                .foregroundStyle(.text00)
            
            HStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(L10n.Dashboard.Weather.uvIndex)
                        .font(.ssFont(.R1))
                        .foregroundStyle(.text03)
                    
                    Text("\(viewModel.uvIndex)")
                        .font(.ssFont(.SB4))
                        .foregroundStyle(.text00)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 8) {
                    Text(L10n.Dashboard.Weather.temperature)
                        .font(.ssFont(.R1))
                        .foregroundStyle(.text03)
                    
                    Text("\(Int(viewModel.temperature))°C")
                        .font(.ssFont(.SB4))
                        .foregroundStyle(.text00)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white00)
            )
        }
    }
}

#Preview {
    DashboardView()
}
