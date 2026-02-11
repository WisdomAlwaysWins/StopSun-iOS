//
//  SEDCalculatorTests.swift
//  StopSunTests
//
//  Created by J on 2/2/26.
//

@testable import StopSun
import XCTest

final class SEDCalculatorTests: XCTestCase {
    // MARK: - Constants Tests
    
    func test_constants() {
        XCTAssertEqual(SEDCalculator.uvIndexToIrradiance, 0.025)
        XCTAssertEqual(SEDCalculator.joulesPerSED, 100.0)
    }
    
    // MARK: - calculateDose Tests
    
    func test_calculateDose_basic() {
        // UV Index 8, 30분
        // 8 * 0.025 * 1800 = 360 J/m²
        let dose = SEDCalculator.calculateDose(uvIndex: 8, durationMinutes: 30)
        XCTAssertEqual(dose, 360.0, accuracy: 0.01)
    }
    
    func test_calculateDose_zeroUV() {
        let dose = SEDCalculator.calculateDose(uvIndex: 0, durationMinutes: 30)
        XCTAssertEqual(dose, 0.0)
    }
    
    func test_calculateDose_zeroDuration() {
        let dose = SEDCalculator.calculateDose(uvIndex: 8, durationMinutes: 0)
        XCTAssertEqual(dose, 0.0)
    }
    
    // MARK: - calculate (SED) Tests
    
    func test_calculate_withoutSPF() {
        // UV Index 8, 30분, SPF 없음
        // Dose = 360 J/m² → SED = 3.6
        let sed = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30)
        XCTAssertEqual(sed, 3.6, accuracy: 0.01)
    }
    
    func test_calculate_withSPF() {
        // UV Index 8, 30분, SPF 30
        // SED = 3.6 ÷ 30 = 0.12
        let sed = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: 30)
        XCTAssertEqual(sed, 0.12, accuracy: 0.001)
    }
    
    func test_calculate_withSPF1() {
        // SPF 1은 효과 없음
        let sedNoSPF = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: nil)
        let sedSPF1 = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: 1)
        XCTAssertEqual(sedNoSPF, sedSPF1, accuracy: 0.01)
    }
    
    func test_calculate_withInvalidSPF() {
        // SPF 0 이하는 무시
        let sedNoSPF = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: nil)
        let sedSPF0 = SEDCalculator.calculate(uvIndex: 8, durationMinutes: 30, spf: 0)
        XCTAssertEqual(sedNoSPF, sedSPF0, accuracy: 0.01)
    }
    
    // MARK: - maxSED Tests
    
    func test_maxSED_allTypes() {
        XCTAssertEqual(SEDCalculator.maxSED(for: .type1), 1.5)
        XCTAssertEqual(SEDCalculator.maxSED(for: .type2), 3.0)
        XCTAssertEqual(SEDCalculator.maxSED(for: .type3), 4.0)
        XCTAssertEqual(SEDCalculator.maxSED(for: .type4), 5.0)
        XCTAssertEqual(SEDCalculator.maxSED(for: .type5), 7.0)
        XCTAssertEqual(SEDCalculator.maxSED(for: .type6), 12.0)
    }
    
    // MARK: - progress Tests
    
    func test_progress_half() {
        // Type III (max 4.0), 현재 2.0 → 50%
        let progress = SEDCalculator.progress(currentSED: 2.0, skinType: .type3)
        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }
    
    func test_progress_full() {
        // Type III (max 4.0), 현재 4.0 → 100%
        let progress = SEDCalculator.progress(currentSED: 4.0, skinType: .type3)
        XCTAssertEqual(progress, 1.0, accuracy: 0.01)
    }
    
    func test_progress_over() {
        // Type III (max 4.0), 현재 5.0 → 125%
        let progress = SEDCalculator.progress(currentSED: 5.0, skinType: .type3)
        XCTAssertEqual(progress, 1.25, accuracy: 0.01)
    }
    
    func test_progress_zero() {
        let progress = SEDCalculator.progress(currentSED: 0, skinType: .type3)
        XCTAssertEqual(progress, 0.0)
    }
    
    // MARK: - remainingSED Tests
    
    func test_remainingSED_normal() {
        // Type III (max 4.0), 현재 2.0 → 남은 2.0
        let remaining = SEDCalculator.remainingSED(currentSED: 2.0, skinType: .type3)
        XCTAssertEqual(remaining, 2.0, accuracy: 0.01)
    }
    
    func test_remainingSED_over() {
        // 이미 초과했으면 0
        let remaining = SEDCalculator.remainingSED(currentSED: 5.0, skinType: .type3)
        XCTAssertEqual(remaining, 0.0)
    }
    
    // MARK: - minutesUntilMax Tests
    
    func test_minutesUntilMax_normal() {
        // Type III (max 4.0), 현재 2.0, UV Index 8
        // 남은 2.0 SED, 분당 SED = 0.12
        // 2.0 / 0.12 = 16.67분
        let minutes = SEDCalculator.minutesUntilMax(
            currentSED: 2.0,
            skinType: .type3,
            uvIndex: 8,
            spf: nil
        )
        XCTAssertEqual(minutes, 16.67, accuracy: 0.1)
    }
    
    func test_minutesUntilMax_withSPF() {
        // SPF 30 적용하면 30배 더 오래 걸림
        let minutesNoSPF = SEDCalculator.minutesUntilMax(
            currentSED: 2.0,
            skinType: .type3,
            uvIndex: 8,
            spf: nil
        )
        let minutesWithSPF = SEDCalculator.minutesUntilMax(
            currentSED: 2.0,
            skinType: .type3,
            uvIndex: 8,
            spf: 30
        )
        XCTAssertEqual(minutesWithSPF, minutesNoSPF * 30, accuracy: 0.1)
    }
    
    func test_minutesUntilMax_alreadyOver() {
        // 이미 초과했으면 0
        let minutes = SEDCalculator.minutesUntilMax(
            currentSED: 5.0,
            skinType: .type3,
            uvIndex: 8,
            spf: nil
        )
        XCTAssertEqual(minutes, 0.0)
    }
    
    func test_minutesUntilMax_zeroUV() {
        // UV Index 0이면 0
        let minutes = SEDCalculator.minutesUntilMax(
            currentSED: 2.0,
            skinType: .type3,
            uvIndex: 0,
            spf: nil
        )
        XCTAssertEqual(minutes, 0.0)
    }
    
    // MARK: - splitExposure Tests
    
    func test_splitExposure_noSunscreen() {
        // Given: 선크림 히스토리 없음
        let start = Date()
        let end = start.addingTimeInterval(30 * 60) // 30분
        let sunscreenHistory: [SunscreenApplication] = []
        
        // When
        let segments = SEDCalculator.splitExposure(
            start: start,
            end: end,
            sunscreenHistory: sunscreenHistory
        )
        
        // Then: 1개 구간, SPF 없음
        XCTAssertEqual(segments.count, 1)
        XCTAssertNil(segments.first?.spfLevel)
        XCTAssertEqual(segments.first?.durationMinutes ?? 0, 30, accuracy: 0.1)
    }
    
    func test_splitExposure_sunscreenBeforeExposure() {
        // Given: 노출 시작 전에 선크림 도포
        let sunscreenTime = Date()
        let start = sunscreenTime.addingTimeInterval(10 * 60) // 10분 후 노출 시작
        let end = start.addingTimeInterval(30 * 60) // 30분 노출
        
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: sunscreenTime
        )
        
        // When
        let segments = SEDCalculator.splitExposure(
            start: start,
            end: end,
            sunscreenHistory: [sunscreen]
        )
        
        // Then: 1개 구간, 전체 SPF 30 적용
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments.first?.spfLevel, .spf30)
        XCTAssertEqual(segments.first?.durationMinutes ?? 0, 30, accuracy: 0.1)
    }
    
    func test_splitExposure_sunscreenDuringExposure() {
        // Given: 30분 노출 중 15분 후 선크림 도포
        let start = Date()
        let sunscreenTime = start.addingTimeInterval(15 * 60) // 15분 후
        let end = start.addingTimeInterval(30 * 60) // 30분
        
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: sunscreenTime
        )
        
        // When
        let segments = SEDCalculator.splitExposure(
            start: start,
            end: end,
            sunscreenHistory: [sunscreen]
        )
        
        // Then: 2개 구간
        XCTAssertEqual(segments.count, 2)
        
        // 첫 구간: 0~15분, SPF 없음
        XCTAssertNil(segments[0].spfLevel)
        XCTAssertEqual(segments[0].durationMinutes, 15, accuracy: 0.1)
        
        // 둘째 구간: 15~30분, SPF 30
        XCTAssertEqual(segments[1].spfLevel, .spf30)
        XCTAssertEqual(segments[1].durationMinutes, 15, accuracy: 0.1)
    }
    
    func test_splitExposure_sunscreenExpiresDuringExposure() {
        // Given: 선크림 도포 후 2시간 만료, 노출이 만료 시점을 걸침
        let sunscreenTime = Date()
        let expiryTime = sunscreenTime.addingTimeInterval(120 * 60) // 2시간 후 만료
        let start = expiryTime.addingTimeInterval(-15 * 60) // 만료 15분 전 노출 시작
        let end = expiryTime.addingTimeInterval(15 * 60) // 만료 15분 후 노출 종료
        
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: sunscreenTime,
            reapplyIntervalMinutes: 120
        )
        
        // When
        let segments = SEDCalculator.splitExposure(
            start: start,
            end: end,
            sunscreenHistory: [sunscreen]
        )
        
        // Then: 2개 구간
        XCTAssertEqual(segments.count, 2)
        
        // 첫 구간: SPF 30 적용 (만료 전)
        XCTAssertEqual(segments[0].spfLevel, .spf30)
        XCTAssertEqual(segments[0].durationMinutes, 15, accuracy: 0.1)
        
        // 둘째 구간: SPF 없음 (만료 후)
        XCTAssertNil(segments[1].spfLevel)
        XCTAssertEqual(segments[1].durationMinutes, 15, accuracy: 0.1)
    }
    
    // MARK: - calculateWithSunscreenHistory Tests
    
    func test_calculateWithSunscreenHistory_noSunscreen() {
        // Given: 선크림 없이 30분, UV 5
        let start = Date()
        let end = start.addingTimeInterval(30 * 60)
        
        // When
        let sed = SEDCalculator.calculateWithSunscreenHistory(
            start: start,
            end: end,
            uvIndex: 5,
            sunscreenHistory: []
        )
        
        // Then: 5 × 0.025 × 1800 ÷ 100 = 2.25
        XCTAssertEqual(sed, 2.25, accuracy: 0.01)
    }
    
    func test_calculateWithSunscreenHistory_fullSPFCoverage() {
        // Given: 노출 전에 선크림 도포
        let sunscreenTime = Date()
        let start = sunscreenTime.addingTimeInterval(10 * 60)
        let end = start.addingTimeInterval(30 * 60)
        let uvIndex = 5.0
        
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: sunscreenTime
        )
        
        // When
        let sed = SEDCalculator.calculateWithSunscreenHistory(
            start: start,
            end: end,
            uvIndex: uvIndex,
            sunscreenHistory: [sunscreen]
        )
        
        // Then: 2.25 ÷ 30 = 0.075
        XCTAssertEqual(sed, 0.075, accuracy: 0.001)
    }
    
    func test_calculateWithSunscreenHistory_sunscreenDuringExposure() {
        // Given: UV 5, 30분 노출, 15분 후 SPF 30 도포
        let start = Date()
        let sunscreenTime = start.addingTimeInterval(15 * 60)
        let end = start.addingTimeInterval(30 * 60)
        let uvIndex = 5.0
        
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: sunscreenTime
        )
        
        // When
        let sed = SEDCalculator.calculateWithSunscreenHistory(
            start: start,
            end: end,
            uvIndex: uvIndex,
            sunscreenHistory: [sunscreen]
        )
        
        // Then:
        // 0~15분 (SPF 없음): 5 × 0.025 × 900 ÷ 100 = 1.125
        // 15~30분 (SPF 30): 1.125 ÷ 30 = 0.0375
        // 합계: 1.1625
        XCTAssertEqual(sed, 1.1625, accuracy: 0.001)
    }
    
    // MARK: - WarningLevel Tests
    
    func test_warningLevel_safe() {
        // Given: 진행률 40%
        let level = WarningLevel.from(progress: 0.4)
        
        // Then
        XCTAssertEqual(level, .safe)
    }
    
    func test_warningLevel_caution() {
        // Given: 진행률 60%
        let level = WarningLevel.from(progress: 0.6)
        
        // Then
        XCTAssertEqual(level, .caution)
    }
    
    func test_warningLevel_warning() {
        // Given: 진행률 90%
        let level = WarningLevel.from(progress: 0.9)
        
        // Then
        XCTAssertEqual(level, .warning)
    }
    
    func test_warningLevel_danger() {
        // Given: 진행률 120%
        let level = WarningLevel.from(progress: 1.2)
        
        // Then
        XCTAssertEqual(level, .danger)
    }
}
