//
//  SPFLevel.swift
//  TarTanning
//
//  Created by J on 7/22/25.
//

import Foundation

enum SPFLevel: Int, CaseIterable, Identifiable, Codable, Sendable {
    case spf15 = 15
    case spf30 = 30
    case spf40 = 40
    case spf50 = 50
    case spf60 = 60
    case spf70 = 70
    case spf80 = 80
    case spf90 = 90
    case spf100 = 100

    var id: Int { rawValue }

    // MARK: - Display
    
    /// Display title (e.g., "SPF 30", "SPF 100+")
    var displayTitle: String {
        if self == .spf100 {
            return "SPF \(rawValue)+"
        }
        return "SPF \(rawValue)"
    }
    
    // MARK: - Data Properties
    
    /// UV 차단율 (%)
    var uvBlockingPercentage: Double {
        switch self {
        case .spf15: 93.3
        case .spf30: 96.7
        case .spf40: 97.5
        case .spf50: 98.0
        case .spf60: 98.3
        case .spf70: 98.6
        case .spf80: 98.75
        case .spf90: 98.9
        case .spf100: 99.0
        }
    }
    
    /// 권장 재도포 시간 (분)
    var recommendedReapplicationMinutes: Int {
        switch self {
        case .spf15: 90
        case .spf30, .spf40: 120
        case .spf50, .spf60: 120
        case .spf70, .spf80, .spf90, .spf100: 120
        }
    }
}
