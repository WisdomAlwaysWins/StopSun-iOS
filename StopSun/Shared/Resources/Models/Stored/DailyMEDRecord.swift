//
//  DailyMEDRecord.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 일일 MED 기록 (UserDefaults 저장)
struct DailyMEDRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    var totalSED: Double
    var recordCount: Int
    
    init(
        id: UUID = UUID(),
        date: Date,
        totalSED: Double = 0,
        recordCount: Int = 0
    ) {
        self.id = id
        self.date = date
        self.totalSED = totalSED
        self.recordCount = recordCount
    }
    
    mutating func addExposure(_ sed: Double) {
        totalSED += sed
        recordCount += 1
    }
}
