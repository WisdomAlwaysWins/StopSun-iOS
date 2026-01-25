//
//  SunScreenService.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// 선크림 관련 비즈니스 로직을 처리하는 Service
/// - Service는 Manager를 사용하여 비즈니스 로직을 수행
final class SunScreenService {

    // MARK: - Singleton
    static let shared = SunScreenService()

    // MARK: - Dependencies
    private let sunScreenManager: SunScreenManager
    private let profileService: UserProfileService

    // MARK: - Initialization
    private init(
        sunScreenManager: SunScreenManager = .shared,
        profileService: UserProfileService = .shared
    ) {
        self.sunScreenManager = sunScreenManager
        self.profileService = profileService
        Log.debug("SunScreenService initialized")
    }

    // MARK: - Business Logic

    /// 선크림 발림 기록
    /// - Parameter spfIndex: SPF 지수 (기본값: 사용자 프로필의 SPF)
    /// - Returns: 성공 여부
    @discardableResult
    func applySunScreen(spfIndex: Int? = nil) -> Bool {
        let spf = spfIndex ?? profileService.fetchCurrentSPF()
        let sunScreen = SunScreenInfo(spfIndex: spf, activationTime: Date())

        Log.info("Applying sunscreen: SPF \(spf)")
        return sunScreenManager.saveSunScreen(sunScreen)
    }

    /// 현재 활성화된 선크림 정보 가져오기
    /// - Returns: 활성 상태의 SunScreenInfo (만료되지 않은 경우)
    func getActiveSunScreen() -> SunScreenInfo? {
        return sunScreenManager.loadActiveSunScreen()
    }

    /// 선크림이 활성 상태인지 확인
    /// - Returns: 활성 여부
    func isSunScreenActive() -> Bool {
        return sunScreenManager.isActive()
    }

    /// 선크림 재발림 알림까지 남은 시간 (분)
    /// - Returns: 남은 시간 (분)
    func getRemainingTime() -> Int {
        return sunScreenManager.remainingMinutes()
    }

    /// 선크림 재발림이 필요한지 확인
    /// - Parameter warningThreshold: 경고 임계값 (분, 기본 30분)
    /// - Returns: 재발림 필요 여부
    func needsReapplication(warningThreshold: Int = 30) -> Bool {
        let remaining = getRemainingTime()

        if remaining == 0 {
            Log.warning("Sunscreen expired - reapplication needed")
            return true
        } else if remaining <= warningThreshold {
            Log.warning("Sunscreen expires soon: \(remaining) minutes remaining")
            return true
        } else {
            return false
        }
    }

    /// 선크림 효과 지속 시간 (전체)
    /// - Returns: 2시간 (초 단위)
    func getSunScreenDuration() -> TimeInterval {
        return SunScreenInfo.duration
    }

    /// 선크림 발림 후 경과 시간 (분)
    /// - Returns: 경과 시간 (분), 없으면 nil
    func getElapsedTime() -> Int? {
        guard let sunScreen = sunScreenManager.loadSunScreen() else {
            return nil
        }

        let elapsed = Date().timeIntervalSince(sunScreen.activationTime)
        return Int(elapsed / 60)
    }

    /// 선크림 발림 후 진행률 (0.0 ~ 1.0)
    /// - Returns: 진행률 (0.0 = 방금 발림, 1.0 = 2시간 경과)
    func getProgressRate() -> Double {
        guard let sunScreen = sunScreenManager.loadSunScreen() else {
            return 1.0 // 없으면 만료로 간주
        }

        let elapsed = Date().timeIntervalSince(sunScreen.activationTime)
        let rate = elapsed / SunScreenInfo.duration

        return min(max(rate, 0.0), 1.0) // 0.0 ~ 1.0 범위로 제한
    }

    /// 선크림 효과 퍼센티지 (100% ~ 0%)
    /// - Returns: 남은 효과 퍼센티지
    func getEffectivenessPercentage() -> Int {
        let progress = getProgressRate()
        let remaining = 1.0 - progress
        return Int(remaining * 100)
    }

    /// 선크림 기록 삭제
    func removeSunScreen() {
        sunScreenManager.deleteSunScreen()
        Log.info("Sunscreen record removed")
    }

    /// UV 차단 효과 계산
    /// - Parameter uvIndex: 현재 UV 지수
    /// - Returns: 차단 후 실제 UV 지수
    func getBlockedUVIndex(originalUV uvIndex: Double) -> Double {
        guard let sunScreen = getActiveSunScreen() else {
            return uvIndex // 선크림 없으면 원래 UV
        }

        let spf = Double(sunScreen.spfIndex)
        let blockedUV = uvIndex / spf

        Log.debug("UV blocked: \(uvIndex) -> \(blockedUV) (SPF \(sunScreen.spfIndex))")

        return blockedUV
    }

    /// 선크림 발림 시각 포맷팅
    /// - Returns: 포맷된 시각 문자열, 없으면 nil
    func getFormattedApplicationTime() -> String? {
        guard let sunScreen = sunScreenManager.loadSunScreen() else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")

        return formatter.string(from: sunScreen.activationTime)
    }
}
