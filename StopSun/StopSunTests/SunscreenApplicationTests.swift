//
//  SunscreenApplicationTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 SunscreenApplication 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class SunscreenApplicationTests: XCTestCase {

    // MARK: - nextReapplyTime Tests

    func test_nextReapplyTime_기본_120분_후이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)

        // Act
        let nextTime = sunscreen.nextReapplyTime

        // Assert - 120분 = 7200초
        let expected = appliedAt.addingTimeInterval(7200)
        XCTAssertEqual(nextTime.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 0.01)
    }

    func test_nextReapplyTime_커스텀_간격() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(
            spfLevel: .spf50,
            appliedAt: appliedAt,
            reapplyIntervalMinutes: 60
        )

        // Act
        let nextTime = sunscreen.nextReapplyTime

        // Assert - 60분 = 3600초
        let expected = appliedAt.addingTimeInterval(3600)
        XCTAssertEqual(nextTime.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 0.01)
    }

    // MARK: - isActive Tests

    func test_isActive_도포_직후는_활성이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)

        // Act & Assert
        XCTAssertTrue(sunscreen.isActive(at: appliedAt))
    }

    func test_isActive_1시간_후는_활성이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)
        let oneHourLater = appliedAt.addingTimeInterval(60 * 60)

        // Act & Assert
        XCTAssertTrue(sunscreen.isActive(at: oneHourLater))
    }

    func test_isActive_119분_후는_활성이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)
        let justBefore = appliedAt.addingTimeInterval(119 * 60)

        // Act & Assert
        XCTAssertTrue(sunscreen.isActive(at: justBefore))
    }

    func test_isActive_120분_후는_비활성이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)
        let exactExpiry = appliedAt.addingTimeInterval(120 * 60)

        // Act & Assert - nextReapplyTime 이상이면 비활성
        XCTAssertFalse(sunscreen.isActive(at: exactExpiry))
    }

    func test_isActive_3시간_후는_비활성이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)
        let threeHoursLater = appliedAt.addingTimeInterval(180 * 60)

        // Act & Assert
        XCTAssertFalse(sunscreen.isActive(at: threeHoursLater))
    }

    func test_isActive_도포_전_시점은_비활성이다() {
        // Arrange
        let appliedAt = Date()
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: appliedAt)
        let beforeApply = appliedAt.addingTimeInterval(-60)

        // Act & Assert
        XCTAssertFalse(sunscreen.isActive(at: beforeApply))
    }

    // MARK: - 기본값 Tests

    func test_기본_reapplyIntervalMinutes는_120이다() {
        let sunscreen = SunscreenApplication(spfLevel: .spf30)
        XCTAssertEqual(sunscreen.reapplyIntervalMinutes, 120)
    }

    func test_spfLevel이_올바르게_저장된다() {
        let sunscreen = SunscreenApplication(spfLevel: .spf50Plus)
        XCTAssertEqual(sunscreen.spfLevel, .spf50Plus)
    }
}
