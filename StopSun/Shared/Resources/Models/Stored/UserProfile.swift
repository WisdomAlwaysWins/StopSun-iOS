//
//  UserProfile.swift
//  TarTanning
//
//  Created by Jun on 7/14/25.
//

import Foundation

struct UserProfile: Codable {
    let id: UUID
    var skinType: SkinType // 유저의 스킨 유형
    var spfLevel: SPFLevel // 유저의 SPF 레벨 (초기값: 30)
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
