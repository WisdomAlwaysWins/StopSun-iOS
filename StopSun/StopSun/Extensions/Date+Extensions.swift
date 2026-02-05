//
//  Date+Extensions.swift
//  StopSun
//
//  Created by J on 1/30/26.
//

import Foundation

// MARK: - Date Extensions

extension Date {
    
    /// API 요청용 날짜 문자열 (yyyy-MM-dd)
    var toAPIDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions

extension String {
    
    /// WeatherAPI 시간 문자열에서 시간 추출
    /// "2025-01-27 14:00" → 14
    var toHour: Int? {
        let components = self.split(separator: " ")
        guard components.count >= 2 else { return nil }
        
        let timePart = components[1]
        let hourString = timePart.split(separator: ":").first
        return hourString.flatMap { Int($0) }
    }
    
    /// WeatherAPI 시간 문자열을 Date로 변환
    /// "2025-01-27 14:00" → Date
    var toDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: self)
    }
}
