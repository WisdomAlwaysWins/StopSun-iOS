//
//  WatchPage.swift
//  StopSunWatch Watch App
//
//  Created by donghee on 3/11/26.
//

import Foundation

/// Watch 메인 TabView 페이지 인덱스
///
/// 페이지 순서가 변경될 경우 이 enum만 수정하면 됩니다.
enum WatchPage: Int {
    /// MED ↔ UVI 전환 화면
    case dashboard = 0
    /// 선크림 타이머 화면
    case timer = 1
}
