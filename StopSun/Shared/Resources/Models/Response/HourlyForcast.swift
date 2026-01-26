//
//  HourlyForcast.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 시간별 UV 예보
struct HourlyForecast: Equatable {
    let hour: Int
    let uvIndex: Double
    let temperature: Double
    let timestamp: Date
    
    var uvLevel: UVLevel { UVLevel(uvIndex: uvIndex) }
}
