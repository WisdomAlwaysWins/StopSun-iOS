//
//  LocalStorageManagerProtocol.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 로컬 저장소 관리 프로토콜
///
/// UserDefaults를 통해 앱 데이터를 저장/조회합니다.
/// 내부적으로 `UserProfileManager`, `SunScreenManager` 등에 위임합니다.
///
/// ## 저장 데이터
/// | 키 | 모델 | 보관 |
/// |----|------|----------|
/// | userProfile | UserProfile | ⭕️ |
/// | activeSunscreen | SunscreenApplication | ⭕️ |
/// | sunscreenHistory | [SunscreenApplication] | ⭕️ |
/// | locationHistory | [LocationRecord] | ⭕️ |
/// | exposures.{date} | [UVExposureRecord] | ⭕️ |
/// | dailyMED.{date} | DailyMEDRecord | ⭕️ |
///
protocol LocalStorageManagerProtocol: AnyObject {
    
    // MARK: - UserProfile
    
    /// 사용자 프로필 로드
    func loadUserProfile() -> UserProfile?
    
    /// 사용자 프로필 저장
    func saveUserProfile(_ profile: UserProfile)
    
    /// 사용자 프로필 로드 (없으면 기본값)
    func loadUserProfileOrDefault() -> UserProfile
    
    /// 피부 타입 업데이트
    func updateSkinType(_ skinType: SkinType)
    
    /// 선크림 SPF 업데이트
    func updateSunscreenSPF(_ spfLevel: SPFLevel)
    
    /// 사용자 프로필 삭제
    func deleteUserProfile()
    
    /// 사용자 프로필 존재 여부
    func hasUserProfile() -> Bool
    
    // MARK: - Onboarding
    
    /// 온보딩 완료 상태 저장
    func saveOnboardingCompleted(_ isCompleted: Bool)
    
    /// 온보딩 완료 상태 조회
    func loadOnboardingCompleted() -> Bool
    
    /// 첫 실행 여부 확인 (최초 1회만 true)
    func checkIsFirstLaunch() -> Bool
    
    // MARK: - Active Sunscreen (현재 바른 선크림)
    
    /// 현재 활성 선크림 저장
    func saveActiveSunscreen(_ sunscreen: SunscreenApplication)
    
    /// 현재 활성 선크림 조회 (만료 여부 무관)
    func loadActiveSunscreen() -> SunscreenApplication?
    
    /// 유효한 활성 선크림 조회 (만료 시 nil)
    func loadActiveValidSunscreen() -> SunscreenApplication?
    
    /// 현재 활성 선크림 삭제
    func deleteActiveSunscreen()
    
    /// 현재 활성 선크림 존재 여부
    func hasActiveSunscreen() -> Bool
    
    /// 선크림 만료까지 남은 시간 (분)
    func fetchRemainingMinutes() -> Int
    
    // MARK: - Sunscreen History (도포 히스토리)
    
    /// 선크림 기록 히스토리 로드
    func loadSunscreenHistory() -> [SunscreenApplication]
    
    /// 선크림 기록 저장
    func saveSunscreenApplication(_ application: SunscreenApplication)
    
    /// 특정 시점에 유효한 SPF 조회
    func getActiveSPF(at date: Date) -> SPFLevel
    
    // MARK: - LocationRecord
    
    /// 위치 히스토리 로드
    func loadLocationHistory() -> [LocationRecord]
    
    /// 위치 기록 저장
    func saveLocationRecord(_ record: LocationRecord)
    
    /// 특정 시점의 위치 조회
    func getLocation(at date: Date) -> LocationRecord?
    
    // MARK: - UVExposureRecord
    
    /// 특정 날짜의 노출 기록 로드
    func loadExposureRecords(for date: Date) -> [UVExposureRecord]
    
    /// 노출 기록 저장
    func saveExposureRecord(_ record: UVExposureRecord)
    
    /// 이미 처리된 HealthKit ID인지 확인
    func isProcessed(healthKitID: UUID) -> Bool
    
    // MARK: - DailyMEDRecord
    
    /// 특정 날짜의 일일 MED 기록 로드
    func loadDailyMEDRecord(for date: Date) -> DailyMEDRecord?
    
    /// 일일 MED 기록 저장
    func saveDailyMEDRecord(_ record: DailyMEDRecord)
    
    // MARK: - Cleanup
    
    /// 오래된 데이터 정리
    func cleanupOldData()
}
