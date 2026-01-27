//
//  SyncCoordinator.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 데이터 동기화 조율자
///
/// HealthKit, Weather, Storage 간의 데이터 흐름을 조율합니다.
///
@MainActor
final class SyncCoordinator: ObservableObject, SyncCoordinatorProtocol {
    
    // MARK: - Published Properties
    
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var todayTotalSED: Double = 0
    @Published private(set) var currentWeather: LocationWeather?
    @Published private(set) var activeSunscreen: SunscreenApplication?
    
    // MARK: - Dependencies
    
    private let healthKit: any HealthKitManagerProtocol
    private let weather: any WeatherManagerProtocol
    private let location: any LocationManagerProtocol
    private let localStorage: any LocalStorageManagerProtocol
    private let notification: any NotificationManagerProtocol
    private let watchConnectivity: any WatchConnectivityManagerProtocol
    
    // MARK: - Initializer
    
    init(
        healthKit: any HealthKitManagerProtocol,
        weather: any WeatherManagerProtocol,
        location: any LocationManagerProtocol,
        localStorage: any LocalStorageManagerProtocol,
        notification: any NotificationManagerProtocol,
        watchConnectivity: any WatchConnectivityManagerProtocol
    ) {
        self.healthKit = healthKit
        self.weather = weather
        self.location = location
        self.localStorage = localStorage
        self.notification = notification
        self.watchConnectivity = watchConnectivity
    }
    
    // MARK: - Sync
    
    func startSync() async {
        // TODO: 구현
    }
    
    func refresh() async {
        // TODO: 구현
    }
    
    // MARK: - User Actions
    
    func applySunscreen(spf: SPFLevel) {
        // TODO: 구현
    }
    
    func stopSunscreen() {
        // TODO: 구현
    }
    
    func updateSkinType(_ skinType: SkinType) {
        // TODO: 구현
    }
    
    func updateSunScreenSPF(_ spfLevel: SPFLevel) {
        // TODO: 구현
    }
}
