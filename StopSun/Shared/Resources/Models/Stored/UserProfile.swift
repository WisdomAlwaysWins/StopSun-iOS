//
//  UserProfile.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import Foundation

/// 사용자 프로필
///
/// 피부 타입과 선호 SPF 설정을 저장합니다.
///
/// ## 저장 정보
/// - 저장 위치: UserDefaults
/// - 저장 키: `stopsun.userProfile`
///
/// ```swift
/// let profile = UserProfile(skinType: .type2, preferredSPF: .spf30)
/// let maxMED = profile.skinType.maxDailyMEDinSED  // 2.5 SED
/// ```
///
struct UserProfile: Codable {
    
    /// 고유 식별자
    let id: UUID
    
    /// 피부 타입
    ///
    /// MED 한계치 계산에 사용됩니다.
    var skinType: SkinType
    
    /// 선호 SPF
    ///
    /// 선크림 도포 시 기본 선택값입니다.
    var spfLevel: SPFLevel
    
    /// 프로필 생성 일시
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        skinType: SkinType,
        spfLevel: SPFLevel = .spf30,
        createdAt: Date = Date()) {
        self.id = id
        self.skinType = skinType
        self.spfLevel = spfLevel
        self.createdAt = createdAt
    }
}

/// Mock
extension UserProfile {
    static let mockUser = UserProfile(skinType: .type3, spfLevel: .spf30)
    
    /// 기본 사용자 프로필 (온보딩 완료 전)
    static let defaultUser = UserProfile(skinType: .type3, spfLevel: .spf30)
}
