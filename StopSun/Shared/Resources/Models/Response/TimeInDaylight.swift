//
//  UVExposure.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// HealthKit 일광 노출 데이터
///
/// Apple Watch가 측정한 `timeInDaylight` 데이터입니다.
/// 처리 후 ``UVExposureRecord``로 변환됩니다.
///
/// ## 데이터 특성
/// - 출처: HealthKit (Apple Watch)
/// - 저장 여부: 저장하지 않음
/// - 지연 도착: 최대 1~2시간
///
/// ## 데이터 흐름
/// ```
/// HealthKit
///     ↓
/// TimeInDaylight
///     ↓
/// SyncCoordinator
///     ↓
/// UVExposureRecord
/// ```
///
struct TimeInDaylight: Identifiable {
    
    /// HealthKit 샘플 UUID
    let id: UUID
    
    /// 노출 시작 시각
    let startTime: Date
    
    /// 노출 종료 시각
    let endTime: Date
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
    
    /// 노출 시간 (분)
    var durationMinutes: Double {
        endTime.timeIntervalSince(startTime) / 60
    }
}
