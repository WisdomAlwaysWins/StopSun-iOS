//
//  MockManagers.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

// MARK: - MockHealthKitManager

final class MockHealthKitManager: HealthKitManagerProtocol {
    var isAvailable: Bool { true }
    var isAuthorized: Bool { true }
    
    func requestAuthorization() async throws {}
    
    func fetchTodayTimeInDaylight() async throws -> [TimeInDaylight] {
        return []
    }
    
    func fetchTimeInDaylight(from start: Date, to end: Date) async throws -> [TimeInDaylight] {
        return []
    }
    
    func enableBackgroundDelivery() async throws {}
}

// MARK: - MockWeatherManager

final class MockWeatherManager: WeatherManagerProtocol {
    func fetchCurrentUVIndex(for location: LocationInfo) async throws -> Double {
        return 2.0
    }
    
    func fetchCurrentWeather(for location: LocationInfo) async throws -> LocationWeather {
        return LocationWeather(
            location: location,
            currentUVIndex: 5.0,
            currentTemperature: 25.0
        )
    }
    
    func fetchUVIndex(for location: LocationInfo, at date: Date) async throws -> Double {
        return 5.0
    }
}

// MARK: - MockLocationManager

final class MockLocationManager: LocationManagerProtocol {
    var isAuthorized: Bool { true }
    
    func requestAuthorization() async {}
    
    func getCurrentLocation() async throws -> LocationInfo {
        return .mockPohang
    }
    
    func startMonitoringSignificantLocationChanges() {}
    func stopMonitoringSignificantLocationChanges() {}
}

// MARK: - MockLocalStorageManager

final class MockLocalStorageManager: LocalStorageManagerProtocol {
    
    private var userProfile: UserProfile? = .mockUser
    private var sunscreenHistory: [SunscreenApplication] = []
    private var locationHistory: [LocationRecord] = []
    
    // MARK: - UserProfile

    func loadUserProfile() -> UserProfile? { userProfile }
    func loadUserProfileOrDefault() -> UserProfile { userProfile ?? .defaultUser }
    func saveUserProfile(_ profile: UserProfile) { userProfile = profile }
    func updateSkinType(_ skinType: SkinType) {
        userProfile?.skinType = skinType
    }
    func updateSunscreenSPF(_ spfLevel: SPFLevel) {
        userProfile?.spfLevel = spfLevel
    }
    func deleteUserProfile() { userProfile = nil }
    func saveOnboardingCompleted(_ isCompleted: Bool) {}
    func loadOnboardingCompleted() -> Bool { true }
    func checkIsFirstLaunch() -> Bool { false }
    
    
    // MARK: - SunscreenApplication

    func loadSunscreenHistory() -> [SunscreenApplication] { sunscreenHistory }
    func loadCurrentSunscreen() -> SunscreenApplication? { sunscreenHistory.last }
    func saveSunscreenApplication(_ application: SunscreenApplication) {
        sunscreenHistory.append(application)
    }
    func deleteSunscreen() { sunscreenHistory.removeAll() }
    func isSunscreenActive() -> Bool {
        guard let current = sunscreenHistory.last else { return false }
        return current.isActive(at: Date())
    }
    func loadSunscreenRemainingMinutes() -> Int {
        guard let current = sunscreenHistory.last else { return 0 }
        let nextReapply = current.nextReapplyTime
        let remaining = nextReapply.timeIntervalSince(Date())
        return remaining > 0 ? Int(remaining / 60) : 0
    }
    func getActiveSPF(at date: Date) -> SPFLevel {
        sunscreenHistory.first { $0.isActive(at: date) }?.spfLevel ?? .none
    }
    
    // MARK: - LocationRecord
    
    func loadLocationHistory() -> [LocationRecord] { locationHistory }
    func saveLocationRecord(_ record: LocationRecord) {
        locationHistory.append(record)
    }
    func getLocation(at date: Date) -> LocationRecord? { nil }
    
    // MARK: - UVExposureRecord
    
    func loadExposureRecords(for date: Date) -> [UVExposureRecord] { [] }
    func saveExposureRecord(_ record: UVExposureRecord) {}
    func isProcessed(healthKitID: UUID) -> Bool { false }
    
    // MARK: - DailyMEDRecord
    
    func loadDailyMEDRecord(for date: Date) -> DailyMEDRecord? { nil }
    func saveDailyMEDRecord(_ record: DailyMEDRecord) {}
    
    // MARK: - Cleanup
    
    func cleanupOldData() {}
}

// MARK: - MockNotificationManager

final class MockNotificationManager: NotificationManagerProtocol {
    var isAuthorized: Bool { true }
    
    func requestAuthorization() async throws {}
    func scheduleReapplyReminder(at date: Date) {}
    func cancelReapplyReminder() {}
    func sendMEDWarning(percentage: Double) {}
    func cancelAllNotifications() {}
}

// MARK: - MockWatchConnectivityManager

final class MockWatchConnectivityManager: WatchConnectivityManagerProtocol {
    var isReachable: Bool { false }
    
    func activate() {}
    func sendUserProfile(_ profile: UserProfile) {}
    func sendSunscreenApplication(_ application: SunscreenApplication) {}
    func sendMEDStatus(totalSED: Double, maxMED: Double) {}
}
