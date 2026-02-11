//
//  IntroductionAnimatedGaugeView.swift
//  StopSun
//
//  Created by taeni on 2/11/26.
//

import SwiftUI

/// 온보딩 전용 MED 게이지 애니메이션 뷰
struct IntroductionAnimatedGaugeView: View {
    
    @State private var currentLevel: MEDLevel = .safe
    @State private var animatedPercentage: Double = MEDLevel.safe.percentage
    @State private var timer: Timer? = nil
    
    /// 레벨 전환 간격
    private let transitionInterval: TimeInterval = 1.5
    
    var body: some View {
        VStack(spacing: 32) {
            
            // 게이지
            MEDGaugeView(
                percentage: animatedPercentage,
                color: currentLevel.color
            )
            
            // 상태 텍스트 영역 (레이아웃 고정)
            VStack(spacing: 12) {
                
                Text(currentLevel.statusTitle)
                    .font(.ssFont(.B1))
                    .foregroundStyle(currentLevel.color)
                    .animation(.easeInOut(duration: 0.4), value: currentLevel)
                
                Text(currentLevel.statusDescription)
                    .font(.ssFont(.R2))
                    .foregroundStyle(.text02)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44) // 텍스트 길이로 인한 흔들림 방지
                    .animation(.easeInOut(duration: 0.4), value: currentLevel)
            }
        }
        .onAppear {
            resetLevel()
            startAnimationLoop()
        }
        .onDisappear {
            stopAnimationLoop()
        }
    }
}

private extension IntroductionAnimatedGaugeView {
    
    func startAnimationLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: transitionInterval, repeats: true) { _ in
            let nextLevel = currentLevel.next
            withAnimation(.easeInOut(duration: 0.5)) {
                currentLevel = nextLevel
                animatedPercentage = nextLevel.percentage
            }
        }
    }
    
    func stopAnimationLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetLevel(){
        currentLevel = .safe
        animatedPercentage = MEDLevel.safe.percentage
    }
}
