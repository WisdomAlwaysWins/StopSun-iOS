//
//  Fonts.swift
//  StopSun
//
//  Created by taeni on 1/8/26.
//

import Foundation

enum TextStyleToken {
    case R1, R2, R3, R4, R5
    case M1, M2, M3, M4
    case SB1, SB2, SB3, SB4, SB5
    case B1, B2
}

struct TextStyleConfig {
    let fontSize: CGFloat
    let lineHeight: CGFloat
    let tracking: CGFloat
}
