//
//  LocationInfo.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import Foundation

/// 현재 위치 정보
///
/// CoreLocation에서 받은 위치 데이터입니다.
/// WeatherAPI 호출 및 UI 표시에 사용됩니다.
///
/// ## 데이터 특성
/// - 출처: CoreLocation
/// - 저장 여부: 저장하지 않음 (``LocationRecord``로 변환)
///
/// ## LocationRecord와의 관계
/// - `LocationInfo`: 현재 위치 (실시간)
/// - `LocationRecord`: 과거 위치 (히스토리)
///
struct LocationInfo: Equatable {
    
    /// 위도
    let latitude: Double
    
    /// 경도
    let longitude: Double
    
    /// 도시 이름
    let cityName: String? 
    
    init(latitude: Double, longitude: Double, cityName: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
    }
}

// Mock
extension LocationInfo {
    static let mockSeoul = LocationInfo(latitude: 37.5665, longitude: 126.9780, cityName: "서울특별시")
    static let mockPohang = LocationInfo(latitude: 36.0190, longitude: 129.3435, cityName: "포항시")
}
