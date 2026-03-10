//
//  WeeklyBarItem.swift
//  StopSun
//
//  Created by J on 2/26/26.
//

import Foundation

/// 주간 차트의 개별 바 데이터
///
/// - `percent`: `nil`이면 데이터 없음, `0`이면 노출 없음
/// - `isToday`: 오늘 날짜 강조 여부
struct WeeklyBarItem: Identifiable, Equatable {
    let dayLabel: String
    let percent: Double
    let exposureMinutes: Int
    let isToday: Bool
    
    var id: String { dayLabel }
}
