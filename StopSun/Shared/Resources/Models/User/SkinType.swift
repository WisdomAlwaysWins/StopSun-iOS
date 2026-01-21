//
//  SkinType.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import Foundation
import SwiftUI

enum SkinType: Int, Codable, CaseIterable, Identifiable {
    case type1 = 1
    case type2
    case type3
    case type4
    case type5
    case type6

    var id: Int { rawValue }

    private var localizationKeyBase: String {
        "skin.type\(rawValue)"
    }

    var titleKey: String {
        "skin.type\(rawValue).title"
    }

    var summaryKey: String {
        "skin.type\(rawValue).summary"
    }

    var descriptionKey: String {
        "skin.type\(rawValue).description"
    }
}

extension SkinType {

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

    /// 피부 타입의 하루 최대 권장 MED 평균값 (J/m²)
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

