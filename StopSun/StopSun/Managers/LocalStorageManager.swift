//
//  LocalStorageManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 로컬 저장소 관리자
///
/// 내부적으로 `UserProfileManager`, `SunScreenManager`에 위임하고,
/// 히스토리/기록 등 추가 저장소를 직접 관리합니다.
///
final class LocalStorageManager: LocalStorageManagerProtocol {
    
    // MARK: - Internal Managers
    
    private let profileManager: UserProfileManager
    private let sunScreenManager: SunScreenManager
    
    // MARK: - Initialization
    
    init(
        profileManager: UserProfileManager = UserProfileManager(),
        sunScreenManager: SunScreenManager = SunScreenManager()
    ) {
        self.profileManager = profileManager
        self.sunScreenManager = sunScreenManager
        Log.debug("LocalStorageManager initialized")
    }
    
    // MARK: - UserProfile (→ UserProfileManager)
    
    func loadUserProfile() -> UserProfile? {
        profileManager.fetchProfile()
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        profileManager.saveProfile(profile)
    }
    
    func loadUserProfileOrDefault() -> UserProfile {
        profileManager.fetchProfileOrDefault()
    }
    
    func updateSkinType(_ skinType: SkinType) {
        profileManager.updateSkinType(skinType)
    }
    
    func updateSunscreenSPF(_ spfLevel: SPFLevel) {
        profileManager.updateSPFLevel(spfLevel)
    }
    
    func deleteUserProfile() {
        profileManager.deleteProfile()
    }
    
    func hasUserProfile() -> Bool {
        profileManager.hasProfile()
    }
    
    // MARK: - Onboarding (→ UserProfileManager)
    
    func saveOnboardingCompleted(_ isCompleted: Bool) {
        profileManager.saveOnboardingCompleted(isCompleted)
    }
    
    func loadOnboardingCompleted() -> Bool {
        profileManager.fetchOnboardingCompleted()
    }
    
    func checkIsFirstLaunch() -> Bool {
        profileManager.checkIsFirstLaunch()
    }
    
    // MARK: - Active Sunscreen (→ SunScreenManager)
    
    func saveActiveSunscreen(_ sunscreen: SunscreenApplication) {
        sunScreenManager.saveSunScreen(sunscreen)
    }
    
    func loadActiveSunscreen() -> SunscreenApplication? {
        sunScreenManager.fetchSunScreen()
    }
    
    func loadActiveValidSunscreen() -> SunscreenApplication? {
        sunScreenManager.fetchActiveSunScreen()
    }
    
    func deleteActiveSunscreen() {
        sunScreenManager.deleteSunScreen()
    }
    
    func hasActiveSunscreen() -> Bool {
        sunScreenManager.hasSunScreen()
    }
    
    func fetchRemainingMinutes() -> Int {
        sunScreenManager.fetchRemainingMinutes()
    }
    
    // MARK: - Sunscreen History
    
    func loadSunscreenHistory() -> [SunscreenApplication] {
        // TODO: 구현
        return []
    }
    
    func saveSunscreenApplication(_ application: SunscreenApplication) {
        // TODO: 구현
    }
    
    func getActiveSPF(at date: Date) -> SPFLevel {
        // TODO: 구현
        return .none
    }
    
    // MARK: - LocationRecord
    
    func loadLocationHistory() -> [LocationRecord] {
        // TODO: 구현
        return []
    }
    
    func saveLocationRecord(_ record: LocationRecord) {
        // TODO: 구현
    }
    
    func getLocation(at date: Date) -> LocationRecord? {
        // TODO: 구현
        return nil
    }
    
    // MARK: - UVExposureRecord
    
    func loadExposureRecords(for date: Date) -> [UVExposureRecord] {
        // TODO: 구현
        return []
    }
    
    func saveExposureRecord(_ record: UVExposureRecord) {
        // TODO: 구현
    }
    
    func isProcessed(healthKitID: UUID) -> Bool {
        // TODO: 구현
        return false
    }
    
    // MARK: - DailyMEDRecord
    
    func loadDailyMEDRecord(for date: Date) -> DailyMEDRecord? {
        // TODO: 구현
        return nil
    }
    
    func saveDailyMEDRecord(_ record: DailyMEDRecord) {
        // TODO: 구현
    }
    
    // MARK: - Cleanup
    
    func cleanupOldData() {
        // TODO: 구현
    }
}
