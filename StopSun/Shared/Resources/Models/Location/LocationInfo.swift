//
//  LocationInfo.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import CoreLocation
import Foundation

struct LocationInfo: Codable {
    let latitude: Double
    let longitude: Double
    let city: String  // 포항시

    var asCLLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case city
    }
}

extension LocationInfo {
    static let mockSeoul = LocationInfo(latitude: 37.5665, longitude: 126.9780, city: "서울특별시")
    static let mockPohang = LocationInfo(latitude: 36.0190, longitude: 129.3435, city: "포항시")
}
