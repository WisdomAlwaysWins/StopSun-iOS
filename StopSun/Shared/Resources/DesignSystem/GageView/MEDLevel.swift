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
enum MEDLevel: CaseIterable, Equatable {
    
    /// MED 0-30%: 안전
    case safe
    
    /// MED 31-51%: 주의
    case caution
    
    /// MED 71-100%: 위험
    case danger
    
    /// MED 100% ~ : 나쁨
    case critical
    
    // MARK: - Properties
    
    /// onboarding 용
    /// 각 레벨의 대표 퍼센트 값
    var percentage: Double {
        switch self {
        case .safe: return 10
        case .caution: return 56
        case .danger: return 73
        case .critical: return 120
        }
    }
    
    /// 레벨별 색상
    var color: Color {
        switch self {
        case .safe: return .gage00      // 안전 (파랑)
        case .caution: return .gage01   // 주의 (주황)
        case .danger: return .gage02    // 위험 (빨강)
        case .critical: return .gage03    // 나쁨 (짙은 빨강)
        }
    }
    
    /// 레벨별 메시지
    var message: String {
        switch self {
        case .safe: return "안전"
        case .caution: return "주의"
        case .danger: return "위험"
        case .critical: return "나쁨"
        }
    }
    
    /// onboarding 용
    /// 다음 레벨
    var next: MEDLevel {
        switch self {
        case .safe: return .caution
        case .caution: return .danger
        case .danger: return .critical
        case .critical: return .safe
        }
    }
    
    // MARK: - Static Methods
    
    /// 퍼센트 값으로부터 레벨 생성
    ///
    /// - Parameter percentage: MED 누적 퍼센트 (0-100)
    /// - Returns: 해당하는 MEDLevel
    static func fromPercentage(_ percentage: Double) -> MEDLevel {
        switch percentage {
        case ...30: return .safe
        case ...50: return .caution
        case ...100: return .danger
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
        case .critical:
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
        case .critical:
            return L10n.MED.Status.Critical.description
        }
    }
}
