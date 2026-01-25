//
//  SunScreenViewModel.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation
import Combine

/// 선크림 관련 View를 위한 ViewModel
/// - ViewModel은 Service를 통해 비즈니스 로직에 접근
/// - View는 Manager/Service에 직접 접근하지 않고 ViewModel을 통해 접근
@MainActor
final class SunScreenViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isActive: Bool = false
    @Published var remainingMinutes: Int = 0
    @Published var progressRate: Double = 0.0
    @Published var effectiveness: Int = 0
    @Published var applicationTime: String = ""
    @Published var needsReapplication: Bool = false

    // MARK: - Dependencies
    private let sunScreenService: SunScreenService
    private let profileService: UserProfileService

    // MARK: - Properties
    private var timer: Timer?

    // MARK: - Initialization
    init(
        sunScreenService: SunScreenService = .shared,
        profileService: UserProfileService = .shared
    ) {
        self.sunScreenService = sunScreenService
        self.profileService = profileService
        Log.debug("SunScreenViewModel initialized")

        setupTimer()
        refresh()
    }

    deinit {
        timer?.invalidate()
        Log.debug("SunScreenViewModel deinitialized")
    }

    // MARK: - Public Methods

    /// 선크림 발림 처리
    func applySunScreen() {
        let success = sunScreenService.applySunScreen()

        if success {
            Log.info("Sunscreen applied successfully")
            refresh()
        } else {
            Log.error("Failed to apply sunscreen")
        }
    }

    /// 커스텀 SPF로 선크림 발림
    /// - Parameter spf: SPF 지수
    func applySunScreen(withSPF spf: Int) {
        let success = sunScreenService.applySunScreen(spfIndex: spf)

        if success {
            Log.info("Sunscreen applied with SPF \(spf)")
            refresh()
        } else {
            Log.error("Failed to apply sunscreen with SPF \(spf)")
        }
    }

    /// 선크림 기록 삭제
    func removeSunScreen() {
        sunScreenService.removeSunScreen()
        Log.info("Sunscreen removed")
        refresh()
    }

    /// 데이터 새로고침
    func refresh() {
        updateState()
        Log.debug("SunScreen state refreshed")
    }

    /// 남은 시간 포맷팅 (예: "1시간 30분")
    func getFormattedRemainingTime() -> String {
        let hours = remainingMinutes / 60
        let minutes = remainingMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "만료됨"
        }
    }

    /// 효과 상태 텍스트 (예: "매우 좋음", "보통", "재발림 필요")
    func getEffectivenessStatus() -> String {
        switch effectiveness {
        case 80...100:
            return "매우 좋음"
        case 50..<80:
            return "보통"
        case 1..<50:
            return "약함"
        default:
            return "재발림 필요"
        }
    }

    /// 효과 상태 색상 (UI용)
    func getEffectivenessColor() -> String {
        switch effectiveness {
        case 80...100:
            return "key00" // 좋음
        case 50..<80:
            return "key01" // 보통
        case 1..<50:
            return "text03" // 약함
        default:
            return "text05" // 재발림 필요
        }
    }

    // MARK: - Private Methods

    /// 타이머 설정 (1분마다 업데이트)
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateState()
            }
        }
    }

    /// 상태 업데이트
    private func updateState() {
        isActive = sunScreenService.isSunScreenActive()
        remainingMinutes = sunScreenService.getRemainingTime()
        progressRate = sunScreenService.getProgressRate()
        effectiveness = sunScreenService.getEffectivenessPercentage()
        applicationTime = sunScreenService.getFormattedApplicationTime() ?? ""
        needsReapplication = sunScreenService.needsReapplication()
    }
}
