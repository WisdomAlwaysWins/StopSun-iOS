//
//  UVExposureRecord.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// UV 노출 기록 (UserDefaults 저장)
struct UVExposureRecord: Codable, Identifiable {
    let id: UUID
    let healthKitID: UUID?
    let startTime: Date
    let endTime: Date
    let averageUV: Double
    let appliedSPF: SPFLevel
    let receivedSED: Double
    
    init(
        id: UUID = UUID(),
        healthKitID: UUID? = nil,
        startTime: Date,
        endTime: Date,
        averageUV: Double,
        appliedSPF: SPFLevel,
        receivedSED: Double
    ) {
        self.id = id
        self.healthKitID = healthKitID
        self.startTime = startTime
        self.endTime = endTime
        self.averageUV = averageUV
        self.appliedSPF = appliedSPF
        self.receivedSED = receivedSED
    }
    
    var durationMinutes: Double {
        endTime.timeIntervalSince(startTime) / 60
    }
}
