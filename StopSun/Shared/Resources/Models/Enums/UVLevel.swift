//
//  UVLevel.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 자외선 위험도 레벨
///
/// WHO 기준에 따른 UV Index 위험도 분류입니다.
///
/// | UV Index | 레벨 | 권장 행동 |
/// |----------|------|----------|
/// | 0-2 | 낮음 | 보호 불필요 |
/// | 3-5 | 보통 | 선크림 권장 |
/// | 6-7 | 높음 | 선크림 필수 |
/// | 8-10 | 매우 높음 | 외출 자제 |
/// | 11+ | 위험 | 실내 권장 |
///
/// ```swift
/// let level = UVLevel(uvIndex: 7.5)  // .high
/// print(level.rawValue)  // "높음"
/// ```
enum UVLevel: String {

    /// UV 0-2: 보호 불필요
    case low = "낮음"
    
    /// UV 3-5: 선크림 권장
    case moderate = "보통"
    
    /// UV 6-7: 선크림 필수
    case high = "높음"
    
    /// UV 8-10: 외출 자제
    case veryHigh = "매우 높음"
    
    /// UV 11+: 실내 권장
    case extreme = "위험"
    
    /// UV Index로 위험도 생성
    ///
    /// - Parameter uvIndex: 자외선 지수 (0.0 이상)
    init(uvIndex: Double) {
        switch uvIndex {
        case ..<3:  self = .low
        case ..<6:  self = .moderate
        case ..<8:  self = .high
        case ..<11: self = .veryHigh
        default:    self = .extreme
        }
    }
}
