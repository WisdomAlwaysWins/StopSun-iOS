//
//  WarningLevelTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 WarningLevel 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class WarningLevelTests: XCTestCase {

    // MARK: - from(progress:) Tests

    func test_progress_0은_safe이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.0), .safe)
    }

    func test_progress_0_29는_safe이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.29), .safe)
    }

    func test_progress_0_3은_caution이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.3), .caution)
    }

    func test_progress_0_49는_caution이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.49), .caution)
    }

    func test_progress_0_5는_warning이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.5), .warning)
    }

    func test_progress_0_69는_warning이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.69), .warning)
    }

    func test_progress_0_7은_danger이다() {
        XCTAssertEqual(WarningLevel.from(progress: 0.7), .danger)
    }

    func test_progress_1_0은_danger이다() {
        XCTAssertEqual(WarningLevel.from(progress: 1.0), .danger)
    }

    func test_progress_1_5_초과해도_danger이다() {
        XCTAssertEqual(WarningLevel.from(progress: 1.5), .danger)
    }

    // MARK: - fromPercentage Tests

    func test_fromPercentage_10은_safe이다() {
        XCTAssertEqual(WarningLevel.fromPercentage(10), .safe)
    }

    func test_fromPercentage_40은_caution이다() {
        XCTAssertEqual(WarningLevel.fromPercentage(40), .caution)
    }

    func test_fromPercentage_60은_warning이다() {
        XCTAssertEqual(WarningLevel.fromPercentage(60), .warning)
    }

    func test_fromPercentage_85는_danger이다() {
        XCTAssertEqual(WarningLevel.fromPercentage(85), .danger)
    }

    func test_fromPercentage는_progress의_100배로_동작한다() {
        // fromPercentage(50) == from(progress: 0.5)
        XCTAssertEqual(
            WarningLevel.fromPercentage(50),
            WarningLevel.from(progress: 0.5)
        )
    }

    // MARK: - shouldNotify Tests

    func test_safe는_알림을_보내지_않는다() {
        XCTAssertFalse(WarningLevel.safe.shouldNotify)
    }

    func test_caution은_알림을_보낸다() {
        XCTAssertTrue(WarningLevel.caution.shouldNotify)
    }

    func test_warning은_알림을_보낸다() {
        XCTAssertTrue(WarningLevel.warning.shouldNotify)
    }

    func test_danger는_알림을_보낸다() {
        XCTAssertTrue(WarningLevel.danger.shouldNotify)
    }

    // MARK: - notificationPriority Tests

    func test_알림_우선순위는_위험할수록_높다() {
        XCTAssertTrue(WarningLevel.safe.notificationPriority < WarningLevel.caution.notificationPriority)
        XCTAssertTrue(WarningLevel.caution.notificationPriority < WarningLevel.warning.notificationPriority)
        XCTAssertTrue(WarningLevel.warning.notificationPriority < WarningLevel.danger.notificationPriority)
    }

    func test_safe_우선순위는_0이다() {
        XCTAssertEqual(WarningLevel.safe.notificationPriority, 0)
    }

    func test_danger_우선순위는_3이다() {
        XCTAssertEqual(WarningLevel.danger.notificationPriority, 3)
    }

    // MARK: - demoPercentage Tests

    func test_demoPercentage_각_레벨별_대표값() {
        XCTAssertEqual(WarningLevel.safe.demoPercentage, 15)
        XCTAssertEqual(WarningLevel.caution.demoPercentage, 40)
        XCTAssertEqual(WarningLevel.warning.demoPercentage, 60)
        XCTAssertEqual(WarningLevel.danger.demoPercentage, 85)
    }

    func test_demoPercentage는_해당_레벨_범위_내에_있다() {
        // safe의 demoPercentage(15)는 safe 범위(0~30)에 포함
        XCTAssertEqual(WarningLevel.fromPercentage(WarningLevel.safe.demoPercentage), .safe)
        XCTAssertEqual(WarningLevel.fromPercentage(WarningLevel.caution.demoPercentage), .caution)
        XCTAssertEqual(WarningLevel.fromPercentage(WarningLevel.warning.demoPercentage), .warning)
        XCTAssertEqual(WarningLevel.fromPercentage(WarningLevel.danger.demoPercentage), .danger)
    }

    // MARK: - next Tests

    func test_next는_순환한다() {
        XCTAssertEqual(WarningLevel.safe.next, .caution)
        XCTAssertEqual(WarningLevel.caution.next, .warning)
        XCTAssertEqual(WarningLevel.warning.next, .danger)
        XCTAssertEqual(WarningLevel.danger.next, .safe)
    }

    func test_next_4번_순환하면_원래_레벨로_돌아온다() {
        var level = WarningLevel.safe
        for _ in 0..<4 {
            level = level.next
        }
        XCTAssertEqual(level, .safe)
    }
}
