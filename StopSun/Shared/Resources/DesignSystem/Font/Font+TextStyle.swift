//
//  Font+TextStyle.swift
//  StopSun
//
//  Created by taeni on 1/8/26.
//

import SwiftUI

extension Font {

    static func ssFont(_ style: TextStyleToken) -> Font {
        switch style {

        case .R1: return .system(size: 12, weight: .regular)
        case .R2: return .system(size: 14, weight: .regular)
        case .R3: return .system(size: 15, weight: .regular)
        case .R4: return .system(size: 15, weight: .regular)
        case .R5: return .system(size: 16, weight: .regular)

        case .M1: return .system(size: 10, weight: .medium)
        case .M2: return .system(size: 15, weight: .medium)
        case .M3: return .system(size: 16, weight: .medium)
        case .M4: return .system(size: 20, weight: .medium)

        case .SB1: return .system(size: 12, weight: .semibold)
        case .SB2: return .system(size: 16, weight: .semibold)
        case .SB3: return .system(size: 20, weight: .semibold)
        case .SB4: return .system(size: 24, weight: .semibold)
        case .SB5: return .system(size: 75, weight: .semibold)

        case .B1: return .system(size: 24, weight: .bold)
        case .B2: return .system(size: 28, weight: .bold)
        }
    }
}
