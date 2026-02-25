//
//  UVIndexView.swift
//  StopSunWatch Watch App
//
//  Created by J on 2/25/26.
//

import SwiftUI

/// UV Index 화면
struct UVIndexView: View {
    
    @ObservedObject var viewModel: WatchMainViewModel
    
    private var level: UVLevel { viewModel.uvLevel }
    
    var body: some View {
        ZStack {
            level.watchBackground.ignoresSafeArea()
            
            VStack {
                Text("\(Int(viewModel.currentUVIndex))")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white00)
                
                // "자외선" 라벨
                Text("자외선")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white00)
            }
            .padding(.bottom, 32)
            
            // 하단 설명
            VStack {
                Spacer()
                
                Text(level.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(.white00)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            }
            .padding(.bottom, 12)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Preview

#Preview("UV 2 낮음") {
    UVIndexView(viewModel: .safe)
}

#Preview("UV 8 높음") {
    UVIndexView(viewModel: .warning)
}
