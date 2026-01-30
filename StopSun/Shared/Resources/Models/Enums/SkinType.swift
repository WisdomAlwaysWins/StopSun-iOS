//
//  SkinType.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import SwiftUI

/// 피츠패트릭 피부 타입 분류
///
/// 피부의 자외선 민감도를 6단계로 분류합니다.
/// 각 타입별 일일 최대 허용 자외선량(MED)이 다릅니다.
///
/// ```swift
/// let user = UserProfile(skinType: .type2)
/// let limit = user.skinType.maxDailyMEDinSED // 2.5 SED
/// ```
///
enum SkinType: Int, Codable, CaseIterable, Identifiable, Sendable {
    case type1 = 1
    case type2
    case type3
    case type4
    case type5
    case type6

    var id: Int { rawValue }

    // MARK: - Localized Strings
    
    var title: String {
        L10n.SkinType.title(rawValue)
    }
    
    var summary: String {
        L10n.SkinType.summary(rawValue)
    }
    
    var skinDescription: String {
        L10n.SkinType.description(rawValue)
    }
    
    var fullDescription: String {
        "\(summary)\n\(skinDescription)"
    }
    
    var maxMEDFormatted: String {
        L10n.SkinType.maxMED(maxMED)
    }

    // MARK: - Visual Properties
    
    var color: Color {
        switch self {
        case .type1: .skintype00
        case .type2: .skintype01
        case .type3: .skintype02
        case .type4: .skintype03
        case .type5: .skintype04
        case .type6: .skintype05
        }
    }

    // MARK: - Data Properties
    
    var maxMED: Double {
        switch self {
        case .type1: 150
        case .type2: 300
        case .type3: 400
        case .type4: 500
        case .type5: 700
        case .type6: 1200
        }
    }
    
    /// 일일 최대 허용 자외선량 (SED 단위)
    var maxDailyMEDinSED: Double {
        switch self {
        case .type1: return 2.0
        case .type2: return 2.5
        case .type3: return 3.0
        case .type4: return 4.5
        case .type5: return 6.0
        case .type6: return 9.0
        }
    }

    var romanNumeral: String {
        switch self {
        case .type1: "I"
        case .type2: "II"
        case .type3: "III"
        case .type4: "IV"
        case .type5: "V"
        case .type6: "VI"
        }
    }
}
