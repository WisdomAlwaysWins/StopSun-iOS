//
//  SunscreenApplication.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 선크림 도포 기록
///
/// 선크림을 바른 시점과 SPF를 기록합니다.
/// HealthKit 데이터 지연 도착 시 과거 시점의 SPF 조회에 사용됩니다.
///
/// ## 저장 정보
/// - 저장 위치: UserDefaults
/// - 저장 키: `stopsun.sunscreenHistory`
///
/// ```swift
/// let record = SunscreenRecord(spfLevel: .spf50)
///
/// // 1시간 후 유효 여부
/// let later = Date().addingTimeInterval(3600)
/// record.isActive(at: later)  // true
/// ```
///
/// - Important: 기본 유효 시간은 2시간(120분)입니다.
struct SunscreenApplication: Codable, Identifiable {

    /// 고유 식별자
     let id: UUID
     
     /// 사용한 SPF
     let spfLevel: SPFLevel
     
     /// 도포 시각
     let appliedAt: Date
     
     /// 재도포 간격 (분)
     ///
     /// 기본값은 120분(2시간)입니다.
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
    
    /// 다음 재도포 시각
    var nextReapplyTime: Date {
        appliedAt.addingTimeInterval(Double(reapplyIntervalMinutes * 60))
    }
    
    /// 특정 시점에 효과가 유효한지 확인
    ///
    /// - Parameter time: 확인할 시점
    /// - Returns: 유효하면 true
    func isActive(at time: Date) -> Bool {
        time >= appliedAt && time < nextReapplyTime
    }
}
