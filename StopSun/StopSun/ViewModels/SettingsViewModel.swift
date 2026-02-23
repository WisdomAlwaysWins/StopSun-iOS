//
//  SettingsViewModel.swift
//  StopSun
//
//  Created by taeni on 2/23/26.
//

import Foundation
import UIKit

/// 설정 화면 ViewModel
///
/// 사용자 프로필 데이터(SkinType, SPFLevel)를 조회/수정하고,
/// 권한 상태를 표시합니다.
///
@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Properties
    
    private(set) var skinType: SkinType
    private(set) var spfLevel: SPFLevel
    
    // MARK: - Dependencies
    
    private let localStorage: any LocalStorageManagerProtocol
    let permissionManager: PermissionManager
    
    // MARK: - Initializer
    
    init(
        localStorage: any LocalStorageManagerProtocol,
        permissionManager: PermissionManager
    ) {
        self.localStorage = localStorage
        self.permissionManager = permissionManager
        
        let profile = localStorage.loadUserProfileOrDefault()
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        
        Log.debug("SettingsViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    /// 피부 타입 변경
    func updateSkinType(_ skinType: SkinType) {
        localStorage.updateSkinType(skinType)
        self.skinType = skinType
        Log.info("Settings: Skin type updated to \(skinType.title)")
    }
    
    /// SPF 레벨 변경
    func updateSPFLevel(_ spfLevel: SPFLevel) {
        localStorage.updateSunscreenSPF(spfLevel)
        self.spfLevel = spfLevel
        Log.info("Settings: SPF updated to \(spfLevel.displayTitle)")
    }
    
    /// 프로필 데이터 새로고침
    func refresh() {
        let profile = localStorage.loadUserProfileOrDefault()
        self.skinType = profile.skinType
        self.spfLevel = profile.spfLevel
        Log.debug("Settings: Profile refreshed")
    }
    
    // MARK: - Display Helpers
    
    /// 현재 피부 타입 표시 텍스트 (예: "4형")
    var skinTypeDisplayText: String {
        skinType.title
    }
    
    /// 현재 SPF 표시 텍스트 (예: "SPF 30")
    var spfDisplayText: String {
        spfLevel.displayTitle
    }
    
    /// 설정 앱으로 이동
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
