//
//  SPFLevel.swift
//  StopSun
//
//  Created by J on 7/22/25.
//

import Foundation

/// 선크림 자외선 차단 지수
///
/// SPF 값에 따른 자외선 차단 효과를 나타냅니다.
/// SED 계산 시 ``protectionFactor``로 나누어 실제 피부 도달량을 계산합니다.
///
/// ```swift
/// // SED 계산 공식
/// let sed = (uvIndex * minutes / 60) / spf.protectionFactor
/// ```
///
/// - Important: 선크림 효과는 도포 후 2시간까지만 유효합니다.
enum SPFLevel: Int, CaseIterable, Identifiable, Codable {
    
    /// 선크림 미사용
    case none = 1
    
    /// SPF 15 - 약한 차단 (93%)
    case spf15 = 15
    
    /// SPF 30 - 보통 차단 (97%)
    case spf30 = 30
    
    /// SPF 50+ - 강한 차단 (98%)
    case spf50 = 50
    
    var id: Int { rawValue }

    // MARK: - Display
    
    /// 화면 표시용 이름 (Localized)
    var displayTitle: String {
        switch self {
        case .none: return L10n.SPF.none
        case .spf15: return L10n.SPF.spf15
        case .spf30: return L10n.SPF.spf30
        case .spf50: return L10n.SPF.spf50
        }
    }
    
    // MARK: - Data Properties
    
    /// 자외선 차단 계수
    ///
    /// SED 계산 시 이 값으로 나눕니다.
    var protectionFactor: Double {
        Double(rawValue)
    }
    
    /// UV 차단율 (%)
    var uvBlockingPercentage: Double {
        switch self {
        case .none: 0.0
        case .spf15: 93.3
        case .spf30: 96.7
        case .spf50: 98.0
        }
    }
    
    /// 권장 재도포 시간 (분)
    var recommendedReapplicationMinutes: Int {
        switch self {
        case .none: 0
        case .spf15: 90
        case .spf30: 120
        case .spf50: 120
        }
    }
}
