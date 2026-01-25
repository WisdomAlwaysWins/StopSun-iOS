//
//  LocationManager.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation

/// LocationInfo 데이터를 UserDefaults에 저장/관리하는 Manager
/// - Manager는 단일 플랫폼의 데이터 저장/로드 기능만 담당
/// - 여러 위치 정보를 배열로 관리 (히스토리)
final class LocationManager {

    // MARK: - Singleton
    static let shared = LocationManager()

    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let currentLocationKey = "currentLocation"
    private let locationHistoryKey = "locationHistory"
    private let maxHistoryCount = 10

    // MARK: - Initialization
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Log.debug("LocationManager initialized")
    }

    // MARK: - Create

    /// 현재 위치 정보 저장
    /// - Parameter location: 저장할 LocationInfo 객체
    /// - Returns: 저장 성공 여부
    @discardableResult
    func saveCurrentLocation(_ location: LocationInfo) -> Bool {
        do {
            let encoded = try JSONEncoder().encode(location)
            userDefaults.set(encoded, forKey: currentLocationKey)
            Log.info("Current location saved: \(location.city)")

            // 히스토리에도 추가
            addToHistory(location)
            return true
        } catch {
            Log.error("Failed to save current location: \(error.localizedDescription)")
            return false
        }
    }

    /// 위치 히스토리에 추가
    /// - Parameter location: 추가할 LocationInfo
    private func addToHistory(_ location: LocationInfo) {
        var history = loadHistory()

        // 중복 제거 (동일한 도시)
        history.removeAll { $0.city == location.city }

        // 최신 항목을 앞에 추가
        history.insert(location, at: 0)

        // 최대 개수 제한
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }

        saveHistory(history)
    }

    /// 위치 히스토리 배열 저장
    private func saveHistory(_ locations: [LocationInfo]) {
        do {
            let encoded = try JSONEncoder().encode(locations)
            userDefaults.set(encoded, forKey: locationHistoryKey)
            Log.debug("Location history saved (\(locations.count) items)")
        } catch {
            Log.error("Failed to save location history: \(error.localizedDescription)")
        }
    }

    // MARK: - Read

    /// 현재 위치 정보 불러오기
    /// - Returns: 저장된 LocationInfo, 없으면 nil
    func loadCurrentLocation() -> LocationInfo? {
        guard let data = userDefaults.data(forKey: currentLocationKey) else {
            Log.debug("No current location found in UserDefaults")
            return nil
        }

        do {
            let location = try JSONDecoder().decode(LocationInfo.self, from: data)
            Log.debug("Current location loaded: \(location.city)")
            return location
        } catch {
            Log.error("Failed to decode current location: \(error.localizedDescription)")
            return nil
        }
    }

    /// 위치 히스토리 불러오기
    /// - Returns: 위치 히스토리 배열 (최신순)
    func loadHistory() -> [LocationInfo] {
        guard let data = userDefaults.data(forKey: locationHistoryKey) else {
            Log.debug("No location history found")
            return []
        }

        do {
            let locations = try JSONDecoder().decode([LocationInfo].self, from: data)
            Log.debug("Location history loaded (\(locations.count) items)")
            return locations
        } catch {
            Log.error("Failed to decode location history: \(error.localizedDescription)")
            return []
        }
    }

    /// 특정 도시의 위치 정보 찾기
    /// - Parameter city: 찾을 도시 이름
    /// - Returns: 해당 도시의 LocationInfo, 없으면 nil
    func findLocation(by city: String) -> LocationInfo? {
        let history = loadHistory()
        let found = history.first { $0.city == city }

        if found != nil {
            Log.debug("Found location for city: \(city)")
        } else {
            Log.debug("No location found for city: \(city)")
        }

        return found
    }

    // MARK: - Update

    /// 현재 위치 업데이트
    /// - Parameter location: 새로운 LocationInfo
    /// - Returns: 업데이트 성공 여부
    @discardableResult
    func updateCurrentLocation(_ location: LocationInfo) -> Bool {
        Log.info("Updating current location to: \(location.city)")
        return saveCurrentLocation(location)
    }

    // MARK: - Delete

    /// 현재 위치 삭제
    func deleteCurrentLocation() {
        userDefaults.removeObject(forKey: currentLocationKey)
        Log.info("Current location deleted")
    }

    /// 위치 히스토리 전체 삭제
    func deleteHistory() {
        userDefaults.removeObject(forKey: locationHistoryKey)
        Log.info("Location history deleted")
    }

    /// 히스토리에서 특정 도시 삭제
    /// - Parameter city: 삭제할 도시 이름
    func deleteFromHistory(city: String) {
        var history = loadHistory()
        history.removeAll { $0.city == city }
        saveHistory(history)
        Log.info("Deleted \(city) from location history")
    }

    // MARK: - Utility

    /// 현재 위치가 저장되어 있는지 확인
    /// - Returns: 저장 여부
    func hasCurrentLocation() -> Bool {
        return userDefaults.data(forKey: currentLocationKey) != nil
    }

    /// 히스토리에 저장된 위치 개수
    /// - Returns: 히스토리 개수
    func historyCount() -> Int {
        return loadHistory().count
    }
}
