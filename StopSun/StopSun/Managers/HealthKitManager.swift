//
//  HealthKitManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// HealthKit 데이터 관리자
final class HealthKitManager: HealthKitManagerProtocol {
    
    var isAvailable: Bool { true }
    var isAuthorized: Bool { false }
    
    func requestAuthorization() async throws {
        // TODO: 구현
    }
    
    func fetchTodayTimeInDaylight() async throws -> [TimeInDaylight] {
        // TODO: 구현
        return []
    }
    
    func fetchTimeInDaylight(from start: Date, to end: Date) async throws -> [TimeInDaylight] {
        // TODO: 구현
        return []
    }
    
    func enableBackgroundDelivery() async throws {
        // TODO: 구현
    }
}
