//
//  UserProfileViewModel.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation
import Combine

/// 사용자 프로필 관련 View를 위한 ViewModel
/// - ViewModel은 Service를 통해 비즈니스 로직에 접근
/// - View는 Manager/Service에 직접 접근하지 않고 ViewModel을 통해 접근
@MainActor
final class UserProfileViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var userProfile: UserProfile
    @Published var skinType: SkinType
    @Published var spfLevel: SPFLevel
    @Published var maxMED: Double = 0.0
    @Published var isOnboardingCompleted: Bool = false

    // MARK: - Dependencies
    private let profileService: UserProfileService

    // MARK: - Initialization

    init(profileService: UserProfileService = .shared) {
        self.profileService = profileService

        let profile = profileService.fetchUserProfile()
        self.userProfile = profile
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        self.maxMED = profile.skinType.maxMED
        self.isOnboardingCompleted = profileService.fetchOnboardingCompleted()

        Log.debug("UserProfileViewModel initialized")
    }

    // MARK: - Public Methods

    /// 피부 타입 변경
    /// - Parameter skinType: 새로운 피부 타입
    func updateSkinType(_ skinType: SkinType) {
        let success = profileService.changeSkinType(to: skinType)

        if success {
            self.skinType = skinType
            self.maxMED = skinType.maxMED
            self.userProfile.skinType = skinType
            Log.info("Skin type updated to: \(skinType.title)")
        } else {
            Log.error("Failed to update skin type")
        }
    }

    /// SPF 레벨 변경
    /// - Parameter spfLevel: 새로운 SPF 레벨
    func updateSPFLevel(_ spfLevel: SPFLevel) {
        let success = profileService.changeSPFLevel(to: spfLevel)

        if success {
            self.spfLevel = spfLevel
            self.userProfile.spfLevel = spfLevel
            Log.info("SPF level updated to: SPF \(spfLevel.rawValue)")
        } else {
            Log.error("Failed to update SPF level")
        }
    }

    /// 프로필 저장 (일괄 저장)
    /// - Parameters:
    ///   - skinType: 피부 타입
    ///   - spfLevel: SPF 레벨
    func saveProfile(skinType: SkinType, spfLevel: SPFLevel) {
        let newProfile = UserProfile(skinType: skinType, spfLevel: spfLevel)
        let success = profileService.saveUserProfile(newProfile)

        if success {
            self.userProfile = newProfile
            self.skinType = skinType
            self.spfLevel = spfLevel
            self.maxMED = skinType.maxMED
            self.isOnboardingCompleted = true
            Log.info("User profile saved successfully")
        } else {
            Log.error("Failed to save user profile")
        }
    }

    /// 프로필 초기화
    func resetProfile() {
        profileService.resetProfile()

        let defaultProfile = UserProfile.defaultUser
        self.userProfile = defaultProfile
        self.skinType = defaultProfile.skinType
        self.spfLevel = defaultProfile.spfLevel
        self.maxMED = defaultProfile.skinType.maxMED
        self.isOnboardingCompleted = false

        Log.info("User profile reset")
    }

    /// 데이터 새로고침
    func refresh() {
        let profile = profileService.fetchUserProfile()
        self.userProfile = profile
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        self.maxMED = profile.skinType.maxMED
        self.isOnboardingCompleted = profileService.fetchOnboardingCompleted()

        Log.debug("User profile refreshed")
    }

    // MARK: - Computed Properties

    /// 현재 피부 타입 설명
    var skinTypeDescription: String {
        skinType.skinDescription
    }

    /// 현재 피부 타입 요약
    var skinTypeSummary: String {
        skinType.summary
    }

    /// 권장 SPF 레벨
    var recommendedSPFLevel: SPFLevel {
        profileService.fetchRecommendedSPFLevel()
    }

    /// 권장 SPF와 현재 SPF 비교
    var isUsingSufficientSPF: Bool {
        spfLevel.rawValue >= recommendedSPFLevel.rawValue
    }

    /// 피부 타입별 주의사항
    var skinCareAdvice: String {
        switch skinType {
        case .type1:
            return "매우 민감한 피부로 햇빛 노출 시 각별한 주의가 필요합니다."
        case .type2:
            return "민감한 피부로 선크림을 꼭 바르고 외출하세요."
        case .type3:
            return "보통 피부이지만 장시간 노출 시 선크림을 사용하세요."
        case .type4:
            return "비교적 건강한 피부이지만 자외선 차단제 사용을 권장합니다."
        case .type5:
            return "강한 피부이지만 장시간 야외 활동 시 보호가 필요합니다."
        case .type6:
            return "매우 강한 피부이지만 자외선 차단은 여전히 중요합니다."
        }
    }

    /// 안전 노출 시간 계산
    /// - Parameters:
    ///   - uvIndex: UV 지수
    ///   - usingSunscreen: 선크림 사용 여부
    /// - Returns: 안전 노출 시간 (분)
    func calculateSafeExposureTime(uvIndex: Double, usingSunscreen: Bool) -> Int {
        return profileService.calculateSafeExposureTime(uvIndex: uvIndex, usingSunscreen: usingSunscreen)
    }

    /// 모든 피부 타입 목록 (UI용)
    var allSkinTypes: [SkinType] {
        SkinType.allCases
    }

    /// 모든 SPF 레벨 목록 (UI용)
    var allSPFLevels: [SPFLevel] {
        SPFLevel.allCases
    }
}
