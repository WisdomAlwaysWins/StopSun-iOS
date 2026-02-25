//
//  WatchMainViewModel.swift
//  StopSunWatch Watch App
//
//  Created by J on 2/25/26.
//

import SwiftUI
import Combine

@MainActor
final class WatchMainViewModel: ObservableObject {
    
    // MARK: - MED / UVI
    
    @Published var currentUVIndex: Double
    @Published var todayTotalSED: Double
    @Published var maxSED: Double
    
    // MARK: - Sunscreen Timer
    
    @Published var sunscreenAppliedAt: Date?
    @Published var sunscreenSPF: Int?
    @Published private(set) var remainingSeconds: Int = 0
    
    private var timerCancellable: AnyCancellable?
    
    static let reapplyInterval: TimeInterval = 2 * 60 * 60
    
    // MARK: - Computed (MED)
    
    var medPercentage: Int {
        guard maxSED > 0 else { return 0 }
        return min(Int(todayTotalSED / maxSED * 100), 999)
    }
    
    var warningLevel: WarningLevel {
        guard maxSED > 0 else { return .safe }
        return .from(progress: todayTotalSED / maxSED)
    }
    
    var uvLevel: UVLevel {
        UVLevel(uvIndex: currentUVIndex)
    }
    
    // MARK: - Computed (Timer)
    
    var timerState: SunscreenTimerState {
        guard let appliedAt = sunscreenAppliedAt else { return .idle }
        return Date().timeIntervalSince(appliedAt) >= Self.reapplyInterval ? .expired : .active
    }
    
    var timerText: String {
        String(format: "%d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }
    
    // MARK: - Init
    
    init(
        currentUVIndex: Double = 0,
        todayTotalSED: Double = 0,
        maxSED: Double = 1.0,
        sunscreenAppliedAt: Date? = nil,
        sunscreenSPF: Int? = nil
    ) {
        self.currentUVIndex = currentUVIndex
        self.todayTotalSED = todayTotalSED
        self.maxSED = maxSED
        self.sunscreenAppliedAt = sunscreenAppliedAt
        self.sunscreenSPF = sunscreenSPF
    }
    
    // MARK: - Timer Actions
    
    func applySunscreen() {
        sunscreenAppliedAt = Date()
        sunscreenSPF = sunscreenSPF ?? 50
        updateRemainingTime()
        // TODO: merge 후 WatchSessionManager로 iPhone에 전송
    }
    
    func startTimer() {
        updateRemainingTime()
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRemainingTime()
            }
    }
    
    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // MARK: - Private
    
    private func updateRemainingTime() {
        guard let appliedAt = sunscreenAppliedAt else {
            remainingSeconds = 0
            return
        }
        let remaining = Self.reapplyInterval - Date().timeIntervalSince(appliedAt)
        remainingSeconds = max(0, Int(remaining))
    }
}

// MARK: - 더미 데이터 Presets

extension WatchMainViewModel {
    
    static var safe: WatchMainViewModel {
        .init(currentUVIndex: 2, todayTotalSED: 0.18, maxSED: 1.0)
    }
    
    static var caution: WatchMainViewModel {
        .init(
            currentUVIndex: 5,
            todayTotalSED: 0.38,
            maxSED: 1.0,
            sunscreenAppliedAt: Date().addingTimeInterval(-37 * 60),
            sunscreenSPF: 50
        )
    }
    
    static var warning: WatchMainViewModel {
        .init(
            currentUVIndex: 8,
            todayTotalSED: 0.65,
            maxSED: 1.0,
            sunscreenAppliedAt: Date().addingTimeInterval(-3 * 60 * 60),
            sunscreenSPF: 50
        )
    }
    
    static var danger: WatchMainViewModel {
        .init(currentUVIndex: 11, todayTotalSED: 0.92, maxSED: 1.0)
    }
}
