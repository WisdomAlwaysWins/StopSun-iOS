//
//  DIContainer.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 의존성 주입 컨테이너
///
/// 앱 전체에서 사용하는 Manager 인스턴스를 관리합니다.
///
/// ## 사용법
/// ```swift
/// // App
/// @main
/// struct StopSunApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environmentObject(DIContainer.shared.syncCoordinator)
///         }
///     }
/// }
///
/// // Preview
/// #Preview {
///     ContentView()
///         .environmentObject(DIContainer.preview.syncCoordinator)
/// }
/// ```
///
final class DIContainer {
    
    // MARK: - Singleton
    
    @MainActor
    static let shared: DIContainer = {
        let localStorage = LocalStorageManager()
        let healthKit = HealthKitManager()
        let weather = WeatherManager()
        let location = LocationManager()
        let notification = NotificationManager()
        let watchConnectivity = WatchConnectivityManager()
        
        let syncCoordinator = SyncCoordinator(
            healthKit: healthKit,
            weather: weather,
            location: location,
            localStorage: localStorage,
            notification: notification,
            watchConnectivity: watchConnectivity
        )
        
        return DIContainer(
            healthKit: healthKit,
            weather: weather,
            location: location,
            localStorage: localStorage,
            notification: notification,
            watchConnectivity: watchConnectivity,
            syncCoordinator: syncCoordinator
        )
    }()
    
    // MARK: - Preview
    
    @MainActor
    static let preview: DIContainer = {
        let localStorage = MockLocalStorageManager()
        let healthKit = MockHealthKitManager()
        let weather = MockWeatherManager()
        let location = MockLocationManager()
        let notification = MockNotificationManager()
        let watchConnectivity = MockWatchConnectivityManager()
        
        let syncCoordinator = SyncCoordinator(
            healthKit: healthKit,
            weather: weather,
            location: location,
            localStorage: localStorage,
            notification: notification,
            watchConnectivity: watchConnectivity
        )
        
        return DIContainer(
            healthKit: healthKit,
            weather: weather,
            location: location,
            localStorage: localStorage,
            notification: notification,
            watchConnectivity: watchConnectivity,
            syncCoordinator: syncCoordinator
        )
    }()
    
    // MARK: - Managers
    
    let healthKit: any HealthKitManagerProtocol
    let weather: any WeatherManagerProtocol
    let location: any LocationManagerProtocol
    let localStorage: any LocalStorageManagerProtocol
    let notification: any NotificationManagerProtocol
    let watchConnectivity: any WatchConnectivityManagerProtocol
    
    /// `@EnvironmentObject`로 사용하기 위해 concrete 타입으로 노출
    let syncCoordinator: SyncCoordinator
    
    // MARK: - Initializer
    
    private init(
        healthKit: any HealthKitManagerProtocol,
        weather: any WeatherManagerProtocol,
        location: any LocationManagerProtocol,
        localStorage: any LocalStorageManagerProtocol,
        notification: any NotificationManagerProtocol,
        watchConnectivity: any WatchConnectivityManagerProtocol,
        syncCoordinator: SyncCoordinator
    ) {
        self.healthKit = healthKit
        self.weather = weather
        self.location = location
        self.localStorage = localStorage
        self.notification = notification
        self.watchConnectivity = watchConnectivity
        self.syncCoordinator = syncCoordinator
    }
}
