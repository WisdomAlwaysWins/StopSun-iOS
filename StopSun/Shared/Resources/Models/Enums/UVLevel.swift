//
//  UVLevel.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// UV 위험도 레벨
enum UVLevel: String {
    case low = "낮음"
    case moderate = "보통"
    case high = "높음"
    case veryHigh = "매우 높음"
    case extreme = "위험"
    
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
