//
//  DashboardViewModel.swift
//  StopSun
//
//  Created by J on 2/21/26.
//

import Foundation

@MainActor
@Observable
final class DashboardViewModel {
    
    // MARK: - State
    
    var currentPage: Int = 0
    
    // MARK: - MED Data
    // TODO: SyncCoordinator.totalSED, maxSED 연결
    
    let medPercentage: Double = 73
    let currentSED: Double = 364.2
    let maxSED: Double = 500.0
    
    var warningLevel: WarningLevel {
        WarningLevel.fromPercentage(medPercentage)
    }
    
    // MARK: - Timer Data
    // TODO: SyncCoordinator.activeSunscreen 연결
    
    let timerRemaining: String = "00:12"
    let isTimerActive: Bool = false
    
    // MARK: - Weather Data
    // TODO: WeatherManager 연결

    let uvIndex: Int = 9
    let temperature: Double = 28.0
    let locationName: String = "포항시"
    
    // MARK: - Formatted

    var formattedDate: String {
        Date().toDayWithWeekdayString
    }
}
