//
//  DailyMEDRecordTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 DailyMEDRecord 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class DailyMEDRecordTests: XCTestCase {

    // MARK: - 초기 상태 Tests

    func test_초기_totalSED는_0이다() {
        let record = DailyMEDRecord(date: Date())
        XCTAssertEqual(record.totalSED, 0)
    }

    func test_초기_recordCount는_0이다() {
        let record = DailyMEDRecord(date: Date())
        XCTAssertEqual(record.recordCount, 0)
    }

    // MARK: - addExposure Tests

    func test_addExposure_SED가_누적된다() {
        // Arrange
        var record = DailyMEDRecord(date: Date())

        // Act
        record.addExposure(1.5)

        // Assert
        XCTAssertEqual(record.totalSED, 1.5, accuracy: 0.001)
    }

    func test_addExposure_여러번_호출하면_SED가_합산된다() {
        // Arrange
        var record = DailyMEDRecord(date: Date())

        // Act
        record.addExposure(1.0)
        record.addExposure(0.5)
        record.addExposure(2.0)

        // Assert
        XCTAssertEqual(record.totalSED, 3.5, accuracy: 0.001)
    }

    func test_addExposure_recordCount가_증가한다() {
        // Arrange
        var record = DailyMEDRecord(date: Date())

        // Act
        record.addExposure(1.0)
        record.addExposure(0.5)

        // Assert
        XCTAssertEqual(record.recordCount, 2)
    }

    // MARK: - medRatio Tests

    func test_medRatio_type3에서_2SED는_50퍼센트이다() {
        // Arrange - Type III의 maxDailyMEDinSED = 4.0
        var record = DailyMEDRecord(date: Date())
        record.addExposure(2.0)

        // Act
        let ratio = record.medRatio(for: .type3)

        // Assert
        XCTAssertEqual(ratio, 0.5, accuracy: 0.001)
    }

    func test_medRatio_type1에서_1_5SED는_100퍼센트이다() {
        // Arrange - Type I의 maxDailyMEDinSED = 1.5
        var record = DailyMEDRecord(date: Date())
        record.addExposure(1.5)

        // Act
        let ratio = record.medRatio(for: .type1)

        // Assert
        XCTAssertEqual(ratio, 1.0, accuracy: 0.001)
    }

    func test_medRatio_초과시_1을_넘는다() {
        // Arrange - Type I의 maxDailyMEDinSED = 1.5
        var record = DailyMEDRecord(date: Date())
        record.addExposure(3.0)

        // Act
        let ratio = record.medRatio(for: .type1)

        // Assert - 3.0 / 1.5 = 2.0
        XCTAssertEqual(ratio, 2.0, accuracy: 0.001)
    }

    func test_medRatio_0SED는_0이다() {
        let record = DailyMEDRecord(date: Date())
        XCTAssertEqual(record.medRatio(for: .type3), 0.0)
    }

    // MARK: - isOverMED Tests

    func test_isOverMED_미만이면_false() {
        // Arrange - Type III의 maxDailyMEDinSED = 4.0
        var record = DailyMEDRecord(date: Date())
        record.addExposure(3.9)

        // Act & Assert
        XCTAssertFalse(record.isOverMED(for: .type3))
    }

    func test_isOverMED_정확히_같으면_true() {
        // Arrange - Type III의 maxDailyMEDinSED = 4.0
        var record = DailyMEDRecord(date: Date())
        record.addExposure(4.0)

        // Act & Assert
        XCTAssertTrue(record.isOverMED(for: .type3))
    }

    func test_isOverMED_초과하면_true() {
        // Arrange
        var record = DailyMEDRecord(date: Date())
        record.addExposure(5.0)

        // Act & Assert
        XCTAssertTrue(record.isOverMED(for: .type3))
    }

    func test_isOverMED_같은_SED라도_피부타입에_따라_결과가_다르다() {
        // Arrange - 2.0 SED
        var record = DailyMEDRecord(date: Date())
        record.addExposure(2.0)

        // Assert
        // Type I (max 1.5): 초과
        XCTAssertTrue(record.isOverMED(for: .type1))
        // Type III (max 4.0): 미달
        XCTAssertFalse(record.isOverMED(for: .type3))
        // Type VI (max 12.0): 미달
        XCTAssertFalse(record.isOverMED(for: .type6))
    }
}
