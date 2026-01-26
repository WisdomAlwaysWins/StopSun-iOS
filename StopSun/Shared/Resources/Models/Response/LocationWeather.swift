//
//  LocationWeather.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 날씨 정보 (API 응답용, 저장 안 함)
struct LocationWeather: Equatable {
    let location: LocationInfo
    let currentUVIndex: Double
    let currentTemperature: Double
    let hourlyForecasts: [HourlyForecast]
    let fetchedAt: Date
    
    var currentUVLevel: UVLevel { UVLevel(uvIndex: currentUVIndex) }
    
    init(
        location: LocationInfo,
        currentUVIndex: Double,
        currentTemperature: Double,
        hourlyForecasts: [HourlyForecast] = [],
        fetchedAt: Date = Date()
    ) {
        self.location = location
        self.currentUVIndex = currentUVIndex
        self.currentTemperature = currentTemperature
        self.hourlyForecasts = hourlyForecasts
        self.fetchedAt = fetchedAt
    }
}
