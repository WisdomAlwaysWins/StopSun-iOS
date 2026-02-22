//
//  SunScreenManager.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// SunscreenApplication 데이터를 UserDefaults에 저장/관리하는 Manager
/// - Manager는 단일 플랫폼의 데이터 저장/로드 기능만 담당
final class SunScreenManager: SunScreenManagerProtocol {

    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let key = "stopsun.sunscreenApplication"

    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Log.debug("SunScreenManager initialized")
    }

    // MARK: - Create

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

    @discardableResult
    func updateSPFLevel(_ spfLevel: SPFLevel) -> Bool {
        let newSunScreen = SunscreenApplication(spfLevel: spfLevel, appliedAt: Date())
        Log.info("Updating SunScreen: SPF \(spfLevel.rawValue)")
        return saveSunScreen(newSunScreen)
    }

    // MARK: - Delete

    func deleteSunScreen() {
        userDefaults.removeObject(forKey: key)
        Log.info("SunScreenInfo deleted")
    }

    // MARK: - Utility

    func hasSunScreen() -> Bool {
        return userDefaults.data(forKey: key) != nil
    }

    func isActive() -> Bool {
        return fetchActiveSunScreen() != nil
    }

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
