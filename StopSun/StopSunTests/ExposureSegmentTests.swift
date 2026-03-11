//
//  ExposureSegmentTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 ExposureSegment, TimeInDaylight 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class ExposureSegmentTests: XCTestCase {

    // MARK: - durationMinutes Tests

    func test_durationMinutes_30분_구간() {
        // Arrange
        let start = Date()
        let end = start.addingTimeInterval(30 * 60)
        let segment = ExposureSegment(startDate: start, endDate: end, spfLevel: nil)

        // Act & Assert
        XCTAssertEqual(segment.durationMinutes, 30.0, accuracy: 0.01)
    }

    func test_durationMinutes_0분_구간() {
        let now = Date()
        let segment = ExposureSegment(startDate: now, endDate: now, spfLevel: nil)
        XCTAssertEqual(segment.durationMinutes, 0.0, accuracy: 0.01)
    }

    // MARK: - durationSeconds Tests

    func test_durationSeconds_30분은_1800초이다() {
        let start = Date()
        let end = start.addingTimeInterval(1800)
        let segment = ExposureSegment(startDate: start, endDate: end, spfLevel: nil)

        XCTAssertEqual(segment.durationSeconds, 1800, accuracy: 0.01)
    }

    // MARK: - hasSunscreen Tests

    func test_hasSunscreen_spfLevel이_nil이면_false() {
        let segment = ExposureSegment(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            spfLevel: nil
        )
        XCTAssertFalse(segment.hasSunscreen)
    }

    func test_hasSunscreen_spfLevel이_none이면_false() {
        let segment = ExposureSegment(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            spfLevel: .none
        )
        XCTAssertFalse(segment.hasSunscreen)
    }

    func test_hasSunscreen_spf30이면_true() {
        let segment = ExposureSegment(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            spfLevel: .spf30
        )
        XCTAssertTrue(segment.hasSunscreen)
    }

    func test_hasSunscreen_spf50Plus이면_true() {
        let segment = ExposureSegment(
            startDate: Date(),
            endDate: Date().addingTimeInterval(60),
            spfLevel: .spf50Plus
        )
        XCTAssertTrue(segment.hasSunscreen)
    }

    // MARK: - Equatable Tests

    func test_같은_id의_segment는_같다() {
        let id = UUID()
        let start = Date()
        let end = start.addingTimeInterval(60)

        let segment1 = ExposureSegment(id: id, startDate: start, endDate: end, spfLevel: .spf30)
        let segment2 = ExposureSegment(id: id, startDate: start, endDate: end, spfLevel: .spf30)

        XCTAssertEqual(segment1, segment2)
    }
}

// MARK: - TimeInDaylight Tests

final class TimeInDaylightTests: XCTestCase {

    func test_durationMinutes_30분_노출() {
        // Arrange
        let start = Date()
        let end = start.addingTimeInterval(30 * 60)
        let exposure = TimeInDaylight(startTime: start, endTime: end)

        // Act & Assert
        XCTAssertEqual(exposure.durationMinutes, 30.0, accuracy: 0.01)
    }

    func test_durationMinutes_90분_노출() {
        let start = Date()
        let end = start.addingTimeInterval(90 * 60)
        let exposure = TimeInDaylight(startTime: start, endTime: end)

        XCTAssertEqual(exposure.durationMinutes, 90.0, accuracy: 0.01)
    }

    func test_durationMinutes_0분_노출() {
        let now = Date()
        let exposure = TimeInDaylight(startTime: now, endTime: now)

        XCTAssertEqual(exposure.durationMinutes, 0.0, accuracy: 0.01)
    }
}
