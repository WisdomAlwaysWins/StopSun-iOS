//
//  SunScreenManager.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// SunscreenApplication 데이터를 UserDefaults에 저장/관리하는 Manager
/// - Manager는 단일 플랫폼의 데이터 저장/로드 기능만 담당
final class SunScreenManager {

    // MARK: - Singleton
    static let shared = SunScreenManager()

    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let key = "stopsun.sunscreenApplication"

    // MARK: - Initialization
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Log.debug("SunScreenManager initialized")
    }

    // MARK: - Create

    /// 선크림 정보 저장
    /// - Parameter sunScreen: 저장할 SunscreenApplication 객체
    /// - Returns: 저장 성공 여부
    @discardableResult
    func saveSunScreen(_ sunScreen: SunscreenApplication) -> Bool {
        do {
            let encoded = try JSONEncoder().encode(sunScreen)
            userDefaults.set(encoded, forKey: key)
            Log.info("SunscreenApplication saved: SPF \(sunScreen.spfLevel.rawValue) at \(sunScreen.appliedAt.formatted())")
            return true
        } catch {
            Log.error("Failed to save SunscreenApplication: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Read

    /// 저장된 선크림 정보 불러오기
    /// - Returns: 저장된 SunscreenApplication, 없으면 nil
    func fetchSunScreen() -> SunscreenApplication? {
        guard let data = userDefaults.data(forKey: key) else {
            Log.debug("No SunscreenApplication found in UserDefaults")
            return nil
        }

        do {
            let sunScreen = try JSONDecoder().decode(SunscreenApplication.self, from: data)
            Log.debug("SunscreenApplication loaded successfully")
            return sunScreen
        } catch {
            Log.error("Failed to decode SunscreenApplication: \(error.localizedDescription)")
            return nil
        }
    }

    /// 현재 활성화된 선크림이 유효한지 확인
    /// - Returns: 선크림이 유효한 경우 SunscreenApplication 반환
    func fetchActiveSunScreen() -> SunscreenApplication? {
        guard let sunScreen = fetchSunScreen() else {
            return nil
        }

        let currentTime = Date()

        if sunScreen.isActive(at: currentTime) {
            let elapsedMinutes = Int(currentTime.timeIntervalSince(sunScreen.appliedAt) / 60)
            Log.debug("SunScreen is still active (elapsed: \(elapsedMinutes)min)")
            return sunScreen
        } else {
            let elapsedMinutes = Int(currentTime.timeIntervalSince(sunScreen.appliedAt) / 60)
            Log.debug("SunScreen expired (elapsed: \(elapsedMinutes)min)")
            return nil
        }
    }

    // MARK: - Update

    /// SPF 레벨 업데이트 (새로운 발림 시각으로 갱신)
    /// - Parameter spfLevel: 새로운 SPF 레벨
    /// - Returns: 업데이트 성공 여부
    @discardableResult
    func updateSPFLevel(_ spfLevel: SPFLevel) -> Bool {
        let newSunScreen = SunscreenApplication(spfLevel: spfLevel, appliedAt: Date())
        Log.info("Updating SunScreen: SPF \(spfLevel.rawValue)")
        return saveSunScreen(newSunScreen)
    }

    // MARK: - Delete

    /// 선크림 정보 삭제
    func deleteSunScreen() {
        userDefaults.removeObject(forKey: key)
        Log.info("SunScreenInfo deleted")
    }

    // MARK: - Utility

    /// 선크림이 저장되어 있는지 확인
    /// - Returns: 저장 여부
    func hasSunScreen() -> Bool {
        return userDefaults.data(forKey: key) != nil
    }

    /// 선크림이 활성 상태인지 확인
    /// - Returns: 활성 여부 (2시간 이내)
    func isActive() -> Bool {
        return fetchActiveSunScreen() != nil
    }

    /// 선크림 만료까지 남은 시간 (분)
    /// - Returns: 남은 시간 (분), 없거나 만료된 경우 0
    func fetchRemainingMinutes() -> Int {
        guard let sunScreen = fetchSunScreen() else {
            return 0
        }

        let currentTime = Date()
        let nextReapplyTime = sunScreen.nextReapplyTime
        let remainingTime = nextReapplyTime.timeIntervalSince(currentTime)

        return remainingTime > 0 ? Int(remainingTime / 60) : 0
    }
}
