//
//  WeatherManagerProtocol.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 날씨 API 관리 프로토콜
///
/// WeatherAPI를 통해 현재 및 과거 UV Index를 조회합니다.
///
/// ## 주요 기능
/// - 현재 날씨 조회
/// - 과거 시점 UV Index 조회 (HealthKit 지연 도착 대응)
///
protocol WeatherManagerProtocol {
    
    /// 현재 날씨 조회
    ///
    /// - Parameter location: 위치 정보
    /// - Returns: 현재 날씨 및 시간별 예보
    func fetchCurrentWeather(for location: LocationInfo) async throws -> LocationWeather
    
    /// 특정 시점의 UV Index 조회
    ///
    /// HealthKit 데이터 지연 도착 시 과거 UV Index 조회에 사용
    ///
    /// - Parameters:
    ///   - location: 위치 정보
    ///   - date: 조회할 시점
    /// - Returns: 해당 시점의 UV Index
    func fetchUVIndex(for location: LocationInfo, at date: Date) async throws -> Double
}
