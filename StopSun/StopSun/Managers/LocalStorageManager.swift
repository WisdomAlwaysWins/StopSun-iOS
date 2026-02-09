//
//  LocalStorageManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 로컬 저장소 관리자
final class LocalStorageManager: LocalStorageManagerProtocol {

    // MARK: - Notification Names

    static let userProfileDidChangeNotification = Notification.Name("UserProfileDidChange")

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // UserProfile Keys
    private let profileKey = "userProfile"
    private let onboardingCompletedKey = "isOnboardingCompleted"
    private let firstLaunchKey = "isFirstLaunch"

    // Sunscreen Keys
    private let sunscreenHistoryKey = "sunscreenHistory"

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Log.debug("LocalStorageManager initialized")
    }

    // MARK: - UserProfile

    func loadUserProfile() -> UserProfile? {
        guard let data = userDefaults.data(forKey: profileKey) else {
            Log.debug("No UserProfile found in UserDefaults")
            return nil
        }

        do {
            let profile = try JSONDecoder().decode(UserProfile.self, from: data)
            Log.debug("UserProfile loaded successfully")
            return profile
        } catch {
            Log.error("Failed to decode UserProfile: \(error.localizedDescription)")
            return nil
        }
    }

    func loadUserProfileOrDefault() -> UserProfile {
        guard let profile = loadUserProfile() else {
            Log.debug("Returning default UserProfile")
            return UserProfile.defaultUser
        }
        return profile
    }

    func saveUserProfile(_ profile: UserProfile) {
        do {
            let encoded = try JSONEncoder().encode(profile)
            userDefaults.set(encoded, forKey: profileKey)
            Log.info("UserProfile saved successfully: \(profile)")

            NotificationCenter.default.post(
                name: Self.userProfileDidChangeNotification,
                object: profile
            )
        } catch {
            Log.error("Failed to save UserProfile: \(error.localizedDescription)")
        }
    }

    func updateSkinType(_ skinType: SkinType) {
        var profile = loadUserProfileOrDefault()
        profile.skinType = skinType
        Log.info("Updating SkinType to: \(skinType.title)")
        saveUserProfile(profile)
    }

    func updateSunscreenSPF(_ spfLevel: SPFLevel) {
        var profile = loadUserProfileOrDefault()
        profile.spfLevel = spfLevel
        Log.info("Updating SPFLevel to: SPF \(spfLevel.rawValue)")
        saveUserProfile(profile)
    }

    func deleteUserProfile() {
        userDefaults.removeObject(forKey: profileKey)
        Log.info("UserProfile deleted")

        NotificationCenter.default.post(
            name: Self.userProfileDidChangeNotification,
            object: nil
        )
    }

    func saveOnboardingCompleted(_ isCompleted: Bool) {
        userDefaults.set(isCompleted, forKey: onboardingCompletedKey)
        Log.info("Onboarding completed status saved: \(isCompleted)")
    }

    func loadOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: onboardingCompletedKey)
    }

    func checkIsFirstLaunch() -> Bool {
        let isFirst = !userDefaults.bool(forKey: firstLaunchKey)

        guard isFirst else {
            return false
        }

        userDefaults.set(true, forKey: firstLaunchKey)
        Log.info("First launch detected and recorded")

        return true
    }
    
    // MARK: - SunscreenApplication

    func loadSunscreenHistory() -> [SunscreenApplication] {
        guard let data = userDefaults.data(forKey: sunscreenHistoryKey) else {
            Log.debug("No Sunscreen history found in UserDefaults")
            return []
        }

        do {
            let history = try JSONDecoder().decode([SunscreenApplication].self, from: data)
            Log.debug("Sunscreen history loaded: \(history.count) items")
            return history
        } catch {
            Log.error("Failed to decode Sunscreen history: \(error.localizedDescription)")
            return []
        }
    }

    func loadCurrentSunscreen() -> SunscreenApplication? {
        let history = loadSunscreenHistory()
        return history.last
    }

    func saveSunscreenApplication(_ application: SunscreenApplication) {
        var history = loadSunscreenHistory()
        history.append(application)

        do {
            let encoded = try JSONEncoder().encode(history)
            userDefaults.set(encoded, forKey: sunscreenHistoryKey)
            Log.info("Sunscreen application saved: SPF \(application.spfLevel.rawValue) at \(application.appliedAt.formatted())")
        } catch {
            Log.error("Failed to save Sunscreen application: \(error.localizedDescription)")
        }
    }

    func deleteSunscreen() {
        userDefaults.removeObject(forKey: sunscreenHistoryKey)
        Log.info("Sunscreen history deleted")
    }

    func isSunscreenActive() -> Bool {
        guard let current = loadCurrentSunscreen() else {
            return false
        }
        let isActive = current.isActive(at: Date())
        Log.debug("Sunscreen active status: \(isActive)")
        return isActive
    }

    func loadSunscreenRemainingMinutes() -> Int {
        guard let current = loadCurrentSunscreen() else {
            return 0
        }

        let currentTime = Date()
        let nextReapplyTime = current.nextReapplyTime
        let remainingTime = nextReapplyTime.timeIntervalSince(currentTime)

        return remainingTime > 0 ? Int(remainingTime / 60) : 0
    }

    func getActiveSPF(at date: Date) -> SPFLevel {
        let history = loadSunscreenHistory()
        let activeSunscreen = history.first { $0.isActive(at: date) }
        return activeSunscreen?.spfLevel ?? .none
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
