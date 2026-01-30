//
//  HourlyForcast.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 시간별 예보
///
/// 특정 시간대의 UV Index와 기온입니다.
///
/// ```swift
/// let forecast = HourlyForecast(hour: 14, uvIndex: 8.5, ...)
/// print("오후 2시 UV: \(forecast.uvIndex)")
/// ```
struct HourlyForecast: Equatable, Identifiable {
    
    /// UUID
    let id = UUID()
    
    /// 시간 (0-23)
    let hour: Int
    
    /// UV Index
    let uvIndex: Double
    
    /// 기온
    let temperature: Double
    
    /// 타임스탬프
    let timestamp: Date
    
    /// UV 위험도
    var uvLevel: UVLevel { UVLevel(uvIndex: uvIndex) }
}
