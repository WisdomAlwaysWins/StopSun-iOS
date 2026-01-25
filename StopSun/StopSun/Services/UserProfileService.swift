//
//  UserProfileService.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// UserProfile 관련 비즈니스 로직을 처리하는 Service
/// - Service는 Manager를 사용하여 비즈니스 로직을 수행
/// - ViewModel은 Service를 통해 데이터에 접근
final class UserProfileService {

    // MARK: - Singleton
    static let shared = UserProfileService()

    // MARK: - Dependencies
    private let profileManager: UserProfileManager

    // MARK: - Initialization
    private init(profileManager: UserProfileManager = .shared) {
        self.profileManager = profileManager
        Log.debug("UserProfileService initialized")
    }

    // MARK: - Business Logic

    /// 사용자 프로필 가져오기 (없으면 기본값)
    /// - Returns: UserProfile
    func fetchUserProfile() -> UserProfile {
        return profileManager.fetchProfileOrDefault()
    }

    /// 사용자 프로필 저장
    /// - Parameter profile: 저장할 프로필
    /// - Returns: 성공 여부
    @discardableResult
    func saveUserProfile(_ profile: UserProfile) -> Bool {
        return profileManager.saveProfile(profile)
    }

    /// 피부 타입 변경
    /// - Parameter skinType: 새로운 피부 타입
    /// - Returns: 성공 여부
    @discardableResult
    func changeSkinType(to skinType: SkinType) -> Bool {
        Log.info("Changing skin type to: \(skinType.title)")
        return profileManager.updateSkinType(skinType)
    }

    /// SPF 레벨 변경
    /// - Parameter spfLevel: 새로운 SPF 레벨
    /// - Returns: 성공 여부
    @discardableResult
    func changeSPFLevel(to spfLevel: SPFLevel) -> Bool {
        Log.info("Changing SPF level to: SPF \(spfLevel.rawValue)")
        return profileManager.updateSPFLevel(spfLevel)
    }

    /// 현재 피부 타입의 최대 MED 값 반환
    /// - Returns: 최대 MED (Minimal Erythema Dose)
    func fetchMaxMED() -> Double {
        let profile = fetchUserProfile()
        return profile.skinType.maxMED
    }

    /// 현재 SPF 레벨 반환
    /// - Returns: SPF 지수
    func fetchCurrentSPF() -> Int {
        let profile = fetchUserProfile()
        return profile.spfLevel.rawValue
    }

    /// 온보딩 완료 여부 확인
    /// - Returns: 온보딩 완료 여부
    func fetchOnboardingCompleted() -> Bool {
        return profileManager.fetchOnboardingCompleted()
    }

    /// 첫 실행 여부 확인
    /// - Returns: 첫 실행 여부
    func checkIsFirstLaunch() -> Bool {
        return profileManager.checkIsFirstLaunch()
    }

    /// 프로필 초기화 (온보딩 다시 하기 등)
    func resetProfile() {
        profileManager.deleteProfile()
        profileManager.saveOnboardingCompleted(false)
        Log.info("User profile reset")
    }

    /// 온보딩 완료 처리
    /// - Parameter profile: 저장할 프로필
    func completeOnboarding(with profile: UserProfile) {
        saveUserProfile(profile)
        profileManager.saveOnboardingCompleted(true)
        Log.info("Onboarding completed")
    }

    /// UV 노출 안전 시간 계산
    /// - Parameters:
    ///   - uvIndex: 현재 UV 지수
    ///   - usingSunscreen: 선크림 사용 여부
    /// - Returns: 안전 노출 시간 (분)
    func calculateSafeExposureTime(uvIndex: Double, usingSunscreen: Bool) -> Int {
        let profile = fetchUserProfile()
        let maxMED = profile.skinType.maxMED

        var safeTime = maxMED / uvIndex

        if usingSunscreen {
            let spfFactor = Double(profile.spfLevel.rawValue)
            safeTime *= spfFactor
        }

        let safeMinutes = Int(safeTime * 10)

        Log.debug("Safe exposure time calculated: \(safeMinutes) minutes (UV: \(uvIndex), SPF: \(usingSunscreen))")

        return max(safeMinutes, 10)
    }

    /// 피부 타입별 권장 SPF 레벨 조회
    /// - Returns: 권장 SPF 레벨
    func fetchRecommendedSPFLevel() -> SPFLevel {
        let profile = fetchUserProfile()

        switch profile.skinType {
        case .type1, .type2:
            return .spf50
        case .type3, .type4:
            return .spf30
        case .type5, .type6:
            return .spf15
        }
    }

    /// 피부 타입 설명 조회
    /// - Returns: 현재 피부 타입 설명
    func fetchSkinTypeDescription() -> String {
        let profile = fetchUserProfile()
        return profile.skinType.skinDescription
    }
}
