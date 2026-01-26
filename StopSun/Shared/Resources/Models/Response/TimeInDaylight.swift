//
//  UVExposure.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// HealthKit 일광시간 데이터 (저장 안함, 단순 처리용)
struct TimeInDaylight: Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var durationMinutes: Double {
        endTime.timeIntervalSince(startTime) / 60
    }
}
