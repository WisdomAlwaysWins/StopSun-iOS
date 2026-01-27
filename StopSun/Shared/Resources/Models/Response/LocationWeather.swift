//
//  LocationWeather.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 날씨 정보
///
/// WeatherAPI에서 받은 현재 날씨와 시간별 예보입니다.
///
/// ## 데이터 특성
/// - 출처: WeatherAPI
/// - 저장 여부: 저장하지 않음
///
struct LocationWeather: Equatable {
    
    /// 위치 정보
    let location: LocationInfo
    
    /// 현재 UV Index
    let currentUVIndex: Double
    
    /// 현재 기온
    let currentTemperature: Double
    
    /// 시간별 예보
    let hourlyForecasts: [HourlyForecast]
    
    /// 데이터 조회 시각
    let fetchedAt: Date
    
    /// 현재 UV 위험도
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
    
    /// 특정 시간대 UV Index 조회
    ///
    /// - Parameter hour: 시간 (0-23)
    /// - Returns: 해당 시간 UV Index
    func uvIndex(at hour: Int) -> Double? {
        hourlyForecasts.first { $0.hour == hour }?.uvIndex
    }
}
