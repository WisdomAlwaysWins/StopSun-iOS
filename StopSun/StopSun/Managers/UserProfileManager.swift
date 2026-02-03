//
//  UserProfileManager.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// UserProfile 데이터를 UserDefaults에 저장/관리하는 Manager
/// - Manager는 단일 플랫폼의 데이터 저장/로드 기능만 담당
/// - 비즈니스 로직은 Service 레이어에서 처리
final class UserProfileManager {

    // MARK: - Singleton

    static let shared = UserProfileManager()

    // MARK: - Notifications

    static let userProfileDidChangeNotification = Notification.Name("UserProfileDidChange")

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let profileKey = "userProfile"
    private let onboardingCompletedKey = "isOnboardingCompleted"
    private let firstLaunchKey = "isFirstLaunch"

    // MARK: - Initialization

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Log.debug("UserProfileManager initialized")
    }

    // MARK: - Create

    /// UserProfile 저장
    /// - Parameter profile: 저장할 UserProfile 객체
    /// - Returns: 저장 성공 여부
    @discardableResult
    func saveProfile(_ profile: UserProfile) -> Bool {
        do {
            let encoded = try JSONEncoder().encode(profile)
            userDefaults.set(encoded, forKey: profileKey)
            Log.info("UserProfile saved successfully: \(profile)")

            NotificationCenter.default.post(
                name: Self.userProfileDidChangeNotification,
                object: profile
            )

            return true
        } catch {
            Log.error("Failed to save UserProfile: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Read

    /// 저장된 UserProfile 조회
    /// - Returns: 저장된 UserProfile, 없으면 nil
    func fetchProfile() -> UserProfile? {
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

    /// 저장된 UserProfile 조회, 없으면 기본값 반환
    /// - Returns: 저장된 UserProfile 또는 기본 UserProfile
    func fetchProfileOrDefault() -> UserProfile {
        guard let profile = fetchProfile() else {
            Log.debug("Returning default UserProfile")
            return UserProfile.defaultUser
        }

        return profile
    }

    // MARK: - Update

    /// SkinType 업데이트
    /// - Parameter skinType: 새로운 SkinType
    /// - Returns: 업데이트 성공 여부
    @discardableResult
    func updateSkinType(_ skinType: SkinType) -> Bool {
        var profile = fetchProfileOrDefault()
        profile.skinType = skinType
        Log.info("Updating SkinType to: \(skinType.title)")
        return saveProfile(profile)
    }

    /// SPFLevel 업데이트
    /// - Parameter spfLevel: 새로운 SPFLevel
    /// - Returns: 업데이트 성공 여부
    @discardableResult
    func updateSPFLevel(_ spfLevel: SPFLevel) -> Bool {
        var profile = fetchProfileOrDefault()
        profile.spfLevel = spfLevel
        Log.info("Updating SPFLevel to: SPF \(spfLevel.rawValue)")
        return saveProfile(profile)
    }

    // MARK: - Delete

    /// UserProfile 삭제
    func deleteProfile() {
        userDefaults.removeObject(forKey: profileKey)
        Log.info("UserProfile deleted")

        NotificationCenter.default.post(
            name: Self.userProfileDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Onboarding Management

    /// 온보딩 완료 상태 저장
    /// - Parameter isCompleted: 온보딩 완료 여부
    func saveOnboardingCompleted(_ isCompleted: Bool) {
        userDefaults.set(isCompleted, forKey: onboardingCompletedKey)
        Log.info("Onboarding completed status saved: \(isCompleted)")
    }

    /// 온보딩 완료 상태 조회
    /// - Returns: 온보딩 완료 여부
    func fetchOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: onboardingCompletedKey)
    }

    /// 첫 실행 여부 확인
    /// - Returns: 첫 실행 여부
    func checkIsFirstLaunch() -> Bool {
        let isFirst = !userDefaults.bool(forKey: firstLaunchKey)

        guard isFirst else {
            return false
        }

        userDefaults.set(true, forKey: firstLaunchKey)
        Log.info("First launch detected and recorded")

        return true
    }

    // MARK: - Utility

    /// UserProfile 저장 여부 확인
    /// - Returns: 저장 여부
    func hasProfile() -> Bool {
        return userDefaults.data(forKey: profileKey) != nil
    }

    // MARK: - Debug Methods

    #if DEBUG
    /// 저장된 모든 데이터 출력 (디버그 전용)
    func printAllStoredData() {
        Log.debug("=== UserProfile Stored Data ===")

        let profile = fetchProfileOrDefault()
        Log.debug("Skin Type: \(profile.skinType.title)")
        Log.debug("SPF Level: \(profile.spfLevel.displayTitle)")
        Log.debug("Onboarding Completed: \(fetchOnboardingCompleted())")
        Log.debug("Has Profile: \(hasProfile())")
        Log.debug("================================")
    }

    /// 모든 데이터 초기화 (디버그 전용)
    func resetAllData() {
        userDefaults.removeObject(forKey: profileKey)
        userDefaults.removeObject(forKey: onboardingCompletedKey)
        userDefaults.removeObject(forKey: firstLaunchKey)
        Log.warning("All UserProfile data has been reset")
    }
    #endif
}
