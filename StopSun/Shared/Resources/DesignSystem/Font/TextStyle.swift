//
//  TextStyle.swift
//  StopSun
//
//  Created by taeni on 1/8/26.
//

import SwiftUI

extension TextStyleToken {

    var config: TextStyleConfig {
        switch self {

        case .R1: return .init(fontSize: 12, lineHeight: 18, tracking: 0)
        case .R2: return .init(fontSize: 14, lineHeight: 21, tracking: 0)
        case .R3: return .init(fontSize: 15, lineHeight: 22.5, tracking: 0)
        case .R4: return .init(fontSize: 15, lineHeight: 24, tracking: 0)
        case .R5: return .init(fontSize: 16, lineHeight: 24, tracking: 0)

        case .M1: return .init(fontSize: 10, lineHeight: 15, tracking: 0)
        case .M2: return .init(fontSize: 15, lineHeight: 22.5, tracking: 0)
        case .M3: return .init(fontSize: 16, lineHeight: 24, tracking: 0)
        case .M4: return .init(fontSize: 20, lineHeight: 30, tracking: 0)

        case .SB1: return .init(fontSize: 12, lineHeight: 18, tracking: 0)
        case .SB2: return .init(fontSize: 16, lineHeight: 24, tracking: 0)
        case .SB3: return .init(fontSize: 20, lineHeight: 30, tracking: 0)
        case .SB4: return .init(fontSize: 24, lineHeight: 36, tracking: 0)
        case .SB5: return .init(fontSize: 75, lineHeight: 112.5, tracking: 0)

        case .B1: return .init(fontSize: 24, lineHeight: 36, tracking: 0)
        case .B2: return .init(fontSize: 28, lineHeight: 42, tracking: 0)
        }
    }
}

extension View {

    func textStyle(_ style: TextStyleToken) -> some View {
        let config = style.config

        return self
            .font(.ssFont(style))
            .lineSpacing(config.lineHeight - config.fontSize)
            .tracking(config.tracking)
    }
}
