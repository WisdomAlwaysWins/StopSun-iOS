//
//  SunScreenManager.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// SunScreenInfo 데이터를 UserDefaults에 저장/관리하는 Manager
/// - Manager는 단일 플랫폼의 데이터 저장/로드 기능만 담당
final class SunScreenManager {

    // MARK: - Singleton
    static let shared = SunScreenManager()

    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let key = "sunScreenInfo"

    // MARK: - Initialization
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Log.debug("SunScreenManager initialized")
    }

    // MARK: - Create

    /// 선크림 정보 저장
    /// - Parameter sunScreen: 저장할 SunScreenInfo 객체
    /// - Returns: 저장 성공 여부
    @discardableResult
    func saveSunScreen(_ sunScreen: SunScreenInfo) -> Bool {
        do {
            let encoded = try JSONEncoder().encode(sunScreen)
            userDefaults.set(encoded, forKey: key)
            Log.info("SunScreenInfo saved: SPF \(sunScreen.spfIndex) at \(sunScreen.activationTime.formatted())")
            return true
        } catch {
            Log.error("Failed to save SunScreenInfo: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Read

    /// 저장된 선크림 정보 불러오기
    /// - Returns: 저장된 SunScreenInfo, 없으면 nil
    func loadSunScreen() -> SunScreenInfo? {
        guard let data = userDefaults.data(forKey: key) else {
            Log.debug("No SunScreenInfo found in UserDefaults")
            return nil
        }

        do {
            let sunScreen = try JSONDecoder().decode(SunScreenInfo.self, from: data)
            Log.debug("SunScreenInfo loaded successfully")
            return sunScreen
        } catch {
            Log.error("Failed to decode SunScreenInfo: \(error.localizedDescription)")
            return nil
        }
    }

    /// 현재 활성화된 선크림이 유효한지 확인
    /// - Returns: 선크림이 2시간 이내에 발랐고 유효한 경우 SunScreenInfo 반환
    func loadActiveSunScreen() -> SunScreenInfo? {
        guard let sunScreen = loadSunScreen() else {
            return nil
        }

        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(sunScreen.activationTime)

        if elapsedTime < SunScreenInfo.duration {
            Log.debug("SunScreen is still active (elapsed: \(Int(elapsedTime/60))min)")
            return sunScreen
        } else {
            Log.debug("SunScreen expired (elapsed: \(Int(elapsedTime/60))min)")
            return nil
        }
    }

    // MARK: - Update

    /// SPF 지수 업데이트 (새로운 발림 시각으로 갱신)
    /// - Parameter spfIndex: 새로운 SPF 지수
    /// - Returns: 업데이트 성공 여부
    @discardableResult
    func updateSPFIndex(_ spfIndex: Int) -> Bool {
        let newSunScreen = SunScreenInfo(spfIndex: spfIndex, activationTime: Date())
        Log.info("Updating SunScreen: SPF \(spfIndex)")
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
        return loadActiveSunScreen() != nil
    }

    /// 선크림 만료까지 남은 시간 (분)
    /// - Returns: 남은 시간 (분), 없거나 만료된 경우 0
    func remainingMinutes() -> Int {
        guard let sunScreen = loadSunScreen() else {
            return 0
        }

        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(sunScreen.activationTime)
        let remainingTime = SunScreenInfo.duration - elapsedTime

        return remainingTime > 0 ? Int(remainingTime / 60) : 0
    }
}
