//
//  SunscreenTimerView.swift
//  StopSunWatch Watch App
//
//  Created by J on 2/25/26.
//

import SwiftUI

/// 선크림 타이머 화면
///
/// Digital Crown으로 MED/UVI에서 전환하여 접근합니다.
///
/// 시안: 타이머_1(미도포), 타이머_2(진행 중), 타이머_3(만료)
///
struct SunscreenTimerView: View {
    
    @ObservedObject var viewModel: WatchMainViewModel
    @State private var remainingSeconds: Int = 0
    @State private var timerUpdater: Timer?
    
    var body: some View {
        ZStack {
            viewModel.timerState.gradient.ignoresSafeArea()
            
            switch viewModel.timerState {
            case .idle:    IdleContent(onStart: viewModel.applySunscreen)
            case .active:  ActiveContent(timerText: viewModel.timerText, onRefresh: viewModel.applySunscreen)
            case .expired: ExpiredContent(onRestart: viewModel.applySunscreen)
            }
        }
        .onAppear { viewModel.startTimer() }
        .onDisappear { viewModel.stopTimer() }
    }
}

// MARK: - Sub Views

private extension SunscreenTimerView {
    
    /// 미도포 (시안: 타이머_1)
    struct IdleContent: View {
        let onStart: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                
                Text(L10n.Timer.startPrompt)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                
//                Text("마지막 기록 없음")
//                    .font(.system(size: 12))
//                    .foregroundStyle(.white.opacity(0.3))
//                    .padding(.top, 12)
                
                Spacer()
                SunscreenActionButton(L10n.Timer.start, action: onStart)
            }
        }
    }
    
    /// 타이머 진행 중 (시안: 타이머_2)
    struct ActiveContent: View {
        let timerText: String
        let onRefresh: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                
                Text(L10n.Timer.untilReapply)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white00)
                
                Text(timerText)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white00)
                    .monospacedDigit()
                
                Spacer()
                SunscreenActionButton(L10n.Timer.refresh, action: onRefresh)
            }
        }
    }
    
    /// 타이머 만료 (시안: 타이머_3)
    struct ExpiredContent: View {
        let onRestart: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                
                Text(L10n.Timer.Alert.reapply)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white00)
                
                Text("0:00")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white00)
                    .monospacedDigit()
                
                Spacer()
                SunscreenActionButton(L10n.Timer.restart, action: onRestart)
            }
        }
    }
}

// MARK: - Preview

#Preview("미도포") { SunscreenTimerView(viewModel: .safe) }
#Preview("진행 중") { SunscreenTimerView(viewModel: .caution) }
#Preview("만료") { SunscreenTimerView(viewModel: .warning) }
