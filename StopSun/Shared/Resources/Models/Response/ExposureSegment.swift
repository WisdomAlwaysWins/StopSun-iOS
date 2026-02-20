//
//  ExposureSegment.swift
//  StopSun
//
//  Created by J on 2/9/26.
//

import Foundation

/// 시간 분할된 UV 노출 구간
///
/// TimeInDaylight와 선크림 타이머가 겹칠 때,
/// 각 구간별로 다른 SPF가 적용될 수 있습니다.
///
/// ## 사용 시나리오
/// ```
/// 선크림: 10:00 ~ 12:00 (SPF 30)
/// TimeInDaylight: 09:30 ~ 10:30
///
/// 분할 결과:
/// - Segment 1: 09:30 ~ 10:00, SPF 없음
/// - Segment 2: 10:00 ~ 10:30, SPF 30
/// ```
///
struct ExposureSegment: Identifiable, Equatable {
    
    let id: UUID
    let startDate: Date
    let endDate: Date
    let spfLevel: SPFLevel?
    
    // MARK: - Initializer
    
    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        spfLevel: SPFLevel?
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.spfLevel = spfLevel
    }
    
    // MARK: - Computed Properties
    
    /// 구간 길이 (분)
    var durationMinutes: Double {
        endDate.timeIntervalSince(startDate) / 60.0
    }
    
    /// 구간 길이 (초)
    var durationSeconds: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    /// SPF 적용 여부
    var hasSunscreen: Bool {
        spfLevel != nil && spfLevel != SPFLevel.none
    }
}

// MARK: - CustomStringConvertible

extension ExposureSegment: CustomStringConvertible {
    var description: String {
        let start = startDate.formatted(date: .omitted, time: .shortened)
        let end = endDate.formatted(date: .omitted, time: .shortened)
        let spf = spfLevel?.displayTitle ?? "없음"
        
        return "\(start)~\(end) (\(Int(durationMinutes))분, SPF \(spf))"
    }
}
