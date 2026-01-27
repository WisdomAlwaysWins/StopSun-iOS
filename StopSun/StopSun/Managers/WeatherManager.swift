//
//  WeatherManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 날씨 API 관리자
final class WeatherManager: WeatherManagerProtocol {
    
    func fetchCurrentWeather(for location: LocationInfo) async throws -> LocationWeather {
        // TODO: 구현
        return LocationWeather(
            location: location,
            currentUVIndex: 0,
            currentTemperature: 0
        )
    }
    
    func fetchUVIndex(for location: LocationInfo, at date: Date) async throws -> Double {
        // TODO: 구현
        return 0
    }
}
