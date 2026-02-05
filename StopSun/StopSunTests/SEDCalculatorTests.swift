//
//  SEDCalculatorTests.swift
//  StopSunTests
//
//  Created by J on 2/2/26.
//

import XCTest
@testable import StopSun

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
}
