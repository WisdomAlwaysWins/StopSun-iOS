//
//  UVExposureRecord.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// UV 노출 기록
///
/// HealthKit `timeInDaylight` 데이터를 처리한 최종 결과입니다.
/// 위치, UV Index, SPF를 조합하여 실제 받은 SED를 계산합니다.
///
/// ## 저장 정보
/// - 저장 위치: UserDefaults
/// - 저장 키: `stopsun.exposures.{yyyyMMdd}`
/// - 보관 기간: 30일
///
/// ## SED 계산 공식
/// ```
/// receivedSED = (averageUV × durationMinutes) / 60 / appliedSPF.protectionFactor
/// ```
///
/// ## 데이터 조합
/// ```
/// TimeInDaylight (HealthKit)
///     + LocationRecord (과거 위치)
///     + WeatherAPI (과거 UV)
///     + SunscreenRecord (과거 SPF)
///     = UVExposureRecord
/// ```
///
struct UVExposureRecord: Codable, Identifiable {

    /// 고유 식별자
    let id: UUID
    
    /// HealthKit 샘플 UUID
    ///
    /// 중복 처리 방지에 사용됩니다.
    let healthKitID: UUID?
    
    /// 노출 시작 시각
    let startTime: Date
    
    /// 노출 종료 시각
    let endTime: Date
    
    /// 노출 시점의 평균 UV Index
    let averageUV: Double
    
    /// 노출 시점에 적용된 SPF
    let appliedSPF: SPFLevel
    
    /// 실제 받은 SED
    ///
    /// SPF 보호 효과를 적용한 최종 자외선량입니다.
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
    
    /// 노출 시간 (분)
    var durationMinutes: Double {
        endTime.timeIntervalSince(startTime) / 60
    }
}
