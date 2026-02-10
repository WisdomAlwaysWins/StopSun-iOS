//
//  String+Extensions.swift
//  StopSun
//
//  Created by J on 2/8/26.
//

import Foundation

// MARK: - String Extensions

extension String {
    
    /// WeatherAPI 시간 문자열에서 시간 추출
    ///
    /// ```swift
    /// "2025-01-27 14:00".toHour  // 14
    /// ```
    var toHour: Int? {
        let components = self.split(separator: " ")
        guard components.count >= 2 else { return nil }
        
        let timePart = components[1]
        let hourString = timePart.split(separator: ":").first
        return hourString.flatMap { Int($0) }
    }
    
    /// WeatherAPI 시간 문자열을 Date로 변환
    ///
    /// ```swift
    /// "2025-01-27 14:00".toWeatherAPIDate  // Date
    /// ```
    var toDate: Date? {
        try? Date(self, strategy: Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: .current
        ))
    }
}
