//
//  MEDLevel.swift
//  StopSun
//
//  Created by taeni on 2/11/26.
//

import SwiftUI

/// MED(Minimal Erythema Dose) 누적 레벨
///
/// 자외선 노출로 인한 홍반(피부 발적) 발생 위험도를 나타냅니다.
///
/// | 퍼센트 | 레벨 | 색상 | 메시지 |
/// |--------|------|------|--------|
/// | 0-40% | 안전 | 파랑 | 안전해요 |
/// | 41-80% | 주의 | 주황 | 주의해요 |
/// | 81-100% | 위험 | 빨강 | 위험해요 |
///
/// ```swift
/// let level = MEDLevel.fromPercentage(97.0)  // .danger
/// print(level.message)  // "위험"
/// ```
enum MEDLevel: CaseIterable {
    
    /// MED 0-40%: 안전
    case safe
    
    /// MED 41-80%: 주의
    case caution
    
    /// MED 81-100%: 위험
    case danger
    
    // MARK: - Properties
    
    /// onboarding 용
    /// 각 레벨의 대표 퍼센트 값
    var percentage: Double {
        switch self {
        case .safe: return 31
        case .caution: return 73
        case .danger: return 97
        }
    }
    
    /// 레벨별 색상
    var color: Color {
        switch self {
        case .safe: return .gage00      // 31% - 안전 (파랑)
        case .caution: return .gage01   // 73% - 주의 (주황)
        case .danger: return .gage02    // 97% - 위험 (빨강)
        }
    }
    
    /// 레벨별 메시지
    var message: String {
        switch self {
        case .danger: return "위험"
        case .caution: return "주의"
        case .safe: return "안전"
        }
    }
    
    /// onboarding 용
    /// 다음 레벨
    var next: MEDLevel {
        switch self {
        case .danger: return .safe
        case .caution: return .danger
        case .safe: return .caution
        }
    }
    
    // MARK: - Static Methods
    
    /// 퍼센트 값으로부터 레벨 생성
    ///
    /// - Parameter percentage: MED 누적 퍼센트 (0-100)
    /// - Returns: 해당하는 MEDLevel
    static func fromPercentage(_ percentage: Double) -> MEDLevel {
        switch percentage {
        case ...40: return .safe
        case ...80: return .caution
        default: return .danger
        }
    }

    var statusTitle: String {
        switch self {
        case .safe:
            return L10n.MED.Status.Safe.title
        case .caution:
            return L10n.MED.Status.Caution.title
        case .danger:
            return L10n.MED.Status.Danger.title
        }
    }

    var statusDescription: String {
        switch self {
        case .safe:
            return L10n.MED.Status.Safe.description
        case .caution:
            return L10n.MED.Status.Caution.description
        case .danger:
            return L10n.MED.Status.Danger.description
        }
    }
}
