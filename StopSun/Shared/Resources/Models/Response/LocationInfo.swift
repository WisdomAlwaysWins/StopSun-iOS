//
//  LocationInfo.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import Foundation

struct LocationInfo: Equatable {
    let latitude: Double
    let longitude: Double
    let cityName: String?  // 포항시
    
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
