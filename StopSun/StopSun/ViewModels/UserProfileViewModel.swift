//
//  UserProfileViewModel.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// 사용자 프로필 관련 View를 위한 ViewModel
@MainActor
@Observable
final class UserProfileViewModel {

    // MARK: - Properties

    private(set) var userProfile: UserProfile
    private(set) var skinType: SkinType
    private(set) var spfLevel: SPFLevel
    private(set) var maxMED: Double = 0.0
    private(set) var isOnboardingCompleted: Bool = false

    // MARK: - Dependencies
    
    private let localStorage: any LocalStorageManagerProtocol

    // MARK: - Initialization

    init(localStorage: any LocalStorageManagerProtocol) {
        self.localStorage = localStorage

        let profile = localStorage.loadUserProfileOrDefault()
        self.userProfile = profile
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        self.maxMED = profile.skinType.maxMED
        self.isOnboardingCompleted = localStorage.loadOnboardingCompleted()

        Log.debug("UserProfileViewModel initialized")
    }

    // MARK: - Public Methods

    func updateSkinType(_ skinType: SkinType) {
        localStorage.updateSkinType(skinType)
        self.skinType = skinType
        self.maxMED = skinType.maxMED
        self.userProfile.skinType = skinType
        Log.info("Skin type updated to: \(skinType.title)")
    }

    func updateSPFLevel(_ spfLevel: SPFLevel) {
        localStorage.updateSunscreenSPF(spfLevel)
        self.spfLevel = spfLevel
        self.userProfile.spfLevel = spfLevel
        Log.info("SPF level updated to: SPF \(spfLevel.rawValue)")
    }

    func saveProfile(skinType: SkinType, spfLevel: SPFLevel) {
        let newProfile = UserProfile(skinType: skinType, spfLevel: spfLevel)
        localStorage.saveUserProfile(newProfile)

        self.userProfile = newProfile
        self.skinType = skinType
        self.spfLevel = spfLevel
        self.maxMED = skinType.maxMED
        self.isOnboardingCompleted = true
        Log.info("User profile saved successfully")
    }

    func resetProfile() {
        localStorage.deleteUserProfile()
        localStorage.saveOnboardingCompleted(false)

        let defaultProfile = UserProfile.defaultUser
        self.userProfile = defaultProfile
        self.skinType = defaultProfile.skinType
        self.spfLevel = defaultProfile.spfLevel
        self.maxMED = defaultProfile.skinType.maxMED
        self.isOnboardingCompleted = false
        Log.info("User profile reset")
    }

    func refresh() {
        let profile = localStorage.loadUserProfileOrDefault()
        self.userProfile = profile
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        self.maxMED = profile.skinType.maxMED
        self.isOnboardingCompleted = localStorage.loadOnboardingCompleted()
        Log.debug("User profile refreshed")
    }

    // MARK: - Computed Properties

    var skinTypeDescription: String { skinType.skinDescription }
    var skinTypeSummary: String { skinType.summary }
    var recommendedSPFLevel: SPFLevel { fetchRecommendedSPFLevel() }
    var isUsingSufficientSPF: Bool { spfLevel.rawValue >= recommendedSPFLevel.rawValue }
    var skinCareAdvice: String { skinType.skinDescription }
    var allSkinTypes: [SkinType] { SkinType.allCases }
    var allSPFLevels: [SPFLevel] { SPFLevel.allCases }

    func calculateSafeExposureTime(uvIndex: Double, usingSunscreen: Bool) -> Int {
        let maxMED = skinType.maxMED
        var safeTime = maxMED / uvIndex
        if usingSunscreen {
            safeTime *= Double(spfLevel.rawValue)
        }
        return max(Int(safeTime * 10), 10)
    }

    // MARK: - Private Methods

    private func fetchRecommendedSPFLevel() -> SPFLevel {
        switch skinType {
        case .type1, .type2: return .spf50
        case .type3, .type4: return .spf30
        case .type5, .type6: return .spf15
        }
    }
}
