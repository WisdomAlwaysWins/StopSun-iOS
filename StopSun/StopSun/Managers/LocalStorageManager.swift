//
//  LocalStorageManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 로컬 저장소 관리자
final class LocalStorageManager: LocalStorageManagerProtocol {
    
    // MARK: - UserProfile
    
    func loadUserProfile() -> UserProfile? {
        // TODO: 구현
        return nil
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        // TODO: 구현
    }
    
    func updateSkinType(_ skinType: SkinType) {
        // TODO: 구현
    }
    
    func updateSunscreenSPF(_ spfLevel: SPFLevel) {
        // TODO: 구현
    }
    
    // MARK: - SunscreenApplication
    
    func loadSunscreenHistory() -> [SunscreenApplication] {
        // TODO: 구현
        return []
    }
    
    func saveSunscreenApplication(_ application: SunscreenApplication) {
        // TODO: 구현
    }
    
    func getActiveSPF(at date: Date) -> SPFLevel {
        // TODO: 구현
        return .none
    }
    
    // MARK: - LocationRecord
    
    func loadLocationHistory() -> [LocationRecord] {
        // TODO: 구현
        return []
    }
    
    func saveLocationRecord(_ record: LocationRecord) {
        // TODO: 구현
    }
    
    func getLocation(at date: Date) -> LocationRecord? {
        // TODO: 구현
        return nil
    }
    
    // MARK: - UVExposureRecord
    
    func loadExposureRecords(for date: Date) -> [UVExposureRecord] {
        // TODO: 구현
        return []
    }
    
    func saveExposureRecord(_ record: UVExposureRecord) {
        // TODO: 구현
    }
    
    func isProcessed(healthKitID: UUID) -> Bool {
        // TODO: 구현
        return false
    }
    
    // MARK: - DailyMEDRecord
    
    func loadDailyMEDRecord(for date: Date) -> DailyMEDRecord? {
        // TODO: 구현
        return nil
    }
    
    func saveDailyMEDRecord(_ record: DailyMEDRecord) {
        // TODO: 구현
    }
    
    // MARK: - Cleanup
    
    func cleanupOldData() {
        // TODO: 구현
    }
}
