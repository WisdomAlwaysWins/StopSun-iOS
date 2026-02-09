//
//  WarningLevel.swift
//  StopSun
//
//  Created by J on 2/8/26.
//

import SwiftUI

/// SED 진행률 기반 경고 레벨
///
/// 일일 권장 자외선 노출량(SED) 대비 현재 진행률에 따른 경고 단계입니다.
///
/// ## 경고 단계
///
/// | 레벨 | 진행률 | 색상 | 권장 행동 |
/// |------|--------|------|----------|
/// | safe | 0~49% | 녹색 | 정상 활동 |
/// | caution | 50~79% | 노란색 | 선크림 확인 |
/// | warning | 80~99% | 주황색 | 그늘 권장 |
/// | danger | 100%+ | 빨간색 | 실내 이동 |
///
/// ## 사용 예시
///
/// ```swift
/// let progress = SEDCalculator.progress(currentSED: 2.0, skinType: .type3)
/// let level = WarningLevel.from(progress: progress)
///
/// // UI에서 사용
/// Text(level.title)
///     .foregroundStyle(level.color)
/// ```
///
enum WarningLevel: String, CaseIterable, Sendable {
    
    /// 0~29%: 안전
    case safe
    
    /// 30~49%: 주의
    case caution
    
    /// 50~69%: 경고
    case warning
    
    /// 70%+: 위험
    case danger
    
    // MARK: - Factory
    
    /// 진행률로부터 경고 레벨 생성
    ///
    /// - Parameter progress: SED 진행률 (0.0 ~ 1.0+)
    /// - Returns: 해당하는 경고 레벨
    ///
    /// ```swift
    /// WarningLevel.from(progress: 0.3)  // .safe
    /// WarningLevel.from(progress: 0.6)  // .caution
    /// WarningLevel.from(progress: 0.85) // .warning
    /// WarningLevel.from(progress: 1.2)  // .danger
    /// ```
    static func from(progress: Double) -> WarningLevel {
        switch progress {
        case ..<0.3:
            return .safe
        case 0.3..<0.5:
            return .caution
        case 0.5..<0.7:
            return .warning
        default:
            return .danger
        }
    }
    
    // MARK: - Display Properties
    
    /// 경고 레벨 제목
    var title: String {
        switch self {
        case .safe: "안전"
        case .caution: "주의"
        case .warning: "경고"
        case .danger: "위험"
        }
    }
    
    /// 경고 레벨 설명
    var description: String {
        switch self {
        case .safe:
            "자외선 노출량이 안전한 수준입니다."
        case .caution:
            "일일 권장량의 절반을 넘었습니다. 선크림을 확인하세요."
        case .warning:
            "곧 일일 권장량에 도달합니다. 그늘을 찾는 것이 좋습니다."
        case .danger:
            "일일 권장량을 초과했습니다! 실내로 이동하세요."
        }
    }
    
    /// 경고 레벨 색상
    var color: Color {
        switch self {
        case .safe: .gage00
        case .caution: .gage01
        case .warning: .gage02
        case .danger: .gage02
        }
    }
    
    // MARK: - Notification Triggers
    
    /// 알림을 보내야 하는 레벨인지 확인
    var shouldNotify: Bool {
        switch self {
        case .safe:
            return false
        case .caution, .warning, .danger:
            return true
        }
    }
    
    /// 알림 우선순위 (높을수록 긴급)
    var notificationPriority: Int {
        switch self {
        case .safe: 0
        case .caution: 1
        case .warning: 2
        case .danger: 3
        }
    }
}
