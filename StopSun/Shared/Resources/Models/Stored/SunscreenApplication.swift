//
//  SunscreenApplication.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 선크림 도포 기록 (UserDefaults 저장)
struct SunscreenApplication: Codable, Identifiable {
    let id: UUID
    let spfLevel: SPFLevel
    let appliedAt: Date
    let reapplyIntervalMinutes: Int
    
    init(
        id: UUID = UUID(),
        spfLevel: SPFLevel,
        appliedAt: Date = Date(),
        reapplyIntervalMinutes: Int = 120
    ) {
        self.id = id
        self.spfLevel = spfLevel
        self.appliedAt = appliedAt
        self.reapplyIntervalMinutes = reapplyIntervalMinutes
    }
    
    var nextReapplyTime: Date {
        appliedAt.addingTimeInterval(Double(reapplyIntervalMinutes * 60))
    }
    
    func isActive(at time: Date) -> Bool {
        time >= appliedAt && time < nextReapplyTime
    }
}
