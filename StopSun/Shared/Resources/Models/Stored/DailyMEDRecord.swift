//
//  DailyMEDRecord.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 일일 MED 누적 기록
///
/// 하루 동안 누적된 총 SED와 노출 횟수를 저장합니다.
///
/// ## 저장 정보
/// - 저장 위치: UserDefaults
/// - 저장 키: `stopsun.dailyMED.{yyyyMMdd}`
/// - 보관 기간: 30일
///
/// ## MED와 SED
/// - SED: 표준 홍반 유발 자외선량 단위
/// - MED: 피부 타입별 홍반 유발 최소량
///
/// ```swift
/// var record = DailyMEDRecord(date: Date())
/// record.addExposure(0.5)
///
/// // MED 비율 계산 (Type II)
/// let ratio = record.medRatio(for: .type2)  // 0.5 / 2.5 = 20%
/// ```
///
struct DailyMEDRecord: Codable, Identifiable {
    
    /// 고유 식별자
    let id: UUID
    
    /// 기록 날짜
    let date: Date
    
    /// 누적 SED
    var totalSED: Double
    
    /// 노출 횟수
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
    
    /// 새 노출 추가
    ///
    /// - Parameter sed: 추가할 SED
    mutating func addExposure(_ sed: Double) {
        totalSED += sed
        recordCount += 1
    }
    
    /// MED 비율 계산
    ///
    /// - Parameter skinType: 피부 타입
    /// - Returns: 0.0 ~ 1.0+ (1.0 이상이면 초과)
    func medRatio(for skinType: SkinType) -> Double {
        totalSED / skinType.maxDailyMEDinSED
    }
    
    /// MED 초과 여부
    ///
    /// - Parameter skinType: 피부 타입
    /// - Returns: 초과 시 true
    func isOverMED(for skinType: SkinType) -> Bool {
        totalSED >= skinType.maxDailyMEDinSED
    }
}
