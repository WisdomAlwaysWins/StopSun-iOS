//
//  UserProfileViewModel.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation
import Combine

/// 사용자 프로필 관련 View를 위한 ViewModel
/// - ViewModel은 Manager를 통해 데이터에 접근
@MainActor
final class UserProfileViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var userProfile: UserProfile
    @Published var skinType: SkinType
    @Published var spfLevel: SPFLevel
    @Published var maxMED: Double = 0.0
    @Published var isOnboardingCompleted: Bool = false

    // MARK: - Dependencies
    private let profileManager: UserProfileManager

    // MARK: - Initialization

    init(profileManager: UserProfileManager = .shared) {
        self.profileManager = profileManager

        let profile = profileManager.fetchProfileOrDefault()
        self.userProfile = profile
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        self.maxMED = profile.skinType.maxMED
        self.isOnboardingCompleted = profileManager.fetchOnboardingCompleted()

        Log.debug("UserProfileViewModel initialized")
    }

    // MARK: - Public Methods

    /// 피부 타입 변경
    /// - Parameter skinType: 새로운 피부 타입
    func updateSkinType(_ skinType: SkinType) {
        let success = profileManager.updateSkinType(skinType)

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
        let success = profileManager.updateSPFLevel(spfLevel)

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
        let success = profileManager.saveProfile(newProfile)

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
        profileManager.deleteProfile()
        profileManager.saveOnboardingCompleted(false)

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
        let profile = profileManager.fetchProfileOrDefault()
        self.userProfile = profile
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        self.maxMED = profile.skinType.maxMED
        self.isOnboardingCompleted = profileManager.fetchOnboardingCompleted()

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
        fetchRecommendedSPFLevel()
    }

    /// 권장 SPF와 현재 SPF 비교
    var isUsingSufficientSPF: Bool {
        spfLevel.rawValue >= recommendedSPFLevel.rawValue
    }

    /// 피부 타입별 주의사항 (Localized)
    var skinCareAdvice: String {
        skinType.skinDescription
    }

    /// 안전 노출 시간 계산
    /// - Parameters:
    ///   - uvIndex: UV 지수
    ///   - usingSunscreen: 선크림 사용 여부
    /// - Returns: 안전 노출 시간 (분)
    func calculateSafeExposureTime(uvIndex: Double, usingSunscreen: Bool) -> Int {
        let maxMED = skinType.maxMED

        var safeTime = maxMED / uvIndex

        if usingSunscreen {
            let spfFactor = Double(spfLevel.rawValue)
            safeTime *= spfFactor
        }

        let safeMinutes = Int(safeTime * 10)

        Log.debug("Safe exposure time calculated: \(safeMinutes) minutes (UV: \(uvIndex), SPF: \(usingSunscreen))")

        return max(safeMinutes, 10)
    }

    /// 모든 피부 타입 목록 (UI용)
    var allSkinTypes: [SkinType] {
        SkinType.allCases
    }

    /// 모든 SPF 레벨 목록 (UI용)
    var allSPFLevels: [SPFLevel] {
        SPFLevel.allCases
    }

    // MARK: - Private Methods

    /// 피부 타입별 권장 SPF 레벨 조회
    private func fetchRecommendedSPFLevel() -> SPFLevel {
        switch skinType {
        case .type1, .type2:
            return .spf50
        case .type3, .type4:
            return .spf30
        case .type5, .type6:
            return .spf15
        }
    }
}
