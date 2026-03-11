//
//  UVLevelTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 UVLevel 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class UVLevelTests: XCTestCase {

    // MARK: - UV Index 범위별 레벨 분류 Tests

    func test_uvIndex_0은_low이다() {
        XCTAssertEqual(UVLevel(uvIndex: 0), .low)
    }

    func test_uvIndex_2는_low이다() {
        XCTAssertEqual(UVLevel(uvIndex: 2.0), .low)
    }

    func test_uvIndex_2_9는_low이다() {
        XCTAssertEqual(UVLevel(uvIndex: 2.9), .low)
    }

    func test_uvIndex_3은_moderate이다() {
        XCTAssertEqual(UVLevel(uvIndex: 3.0), .moderate)
    }

    func test_uvIndex_5는_moderate이다() {
        XCTAssertEqual(UVLevel(uvIndex: 5.0), .moderate)
    }

    func test_uvIndex_5_9는_moderate이다() {
        XCTAssertEqual(UVLevel(uvIndex: 5.9), .moderate)
    }

    func test_uvIndex_6은_high이다() {
        XCTAssertEqual(UVLevel(uvIndex: 6.0), .high)
    }

    func test_uvIndex_7_9는_high이다() {
        XCTAssertEqual(UVLevel(uvIndex: 7.9), .high)
    }

    func test_uvIndex_8은_veryHigh이다() {
        XCTAssertEqual(UVLevel(uvIndex: 8.0), .veryHigh)
    }

    func test_uvIndex_10은_veryHigh이다() {
        XCTAssertEqual(UVLevel(uvIndex: 10.0), .veryHigh)
    }

    func test_uvIndex_10_9는_veryHigh이다() {
        XCTAssertEqual(UVLevel(uvIndex: 10.9), .veryHigh)
    }

    func test_uvIndex_11은_extreme이다() {
        XCTAssertEqual(UVLevel(uvIndex: 11.0), .extreme)
    }

    func test_uvIndex_15는_extreme이다() {
        XCTAssertEqual(UVLevel(uvIndex: 15.0), .extreme)
    }

    // MARK: - 경계값 Tests

    func test_경계값_3_미만은_low_3_이상은_moderate() {
        XCTAssertEqual(UVLevel(uvIndex: 2.99), .low)
        XCTAssertEqual(UVLevel(uvIndex: 3.00), .moderate)
    }

    func test_경계값_6_미만은_moderate_6_이상은_high() {
        XCTAssertEqual(UVLevel(uvIndex: 5.99), .moderate)
        XCTAssertEqual(UVLevel(uvIndex: 6.00), .high)
    }

    func test_경계값_8_미만은_high_8_이상은_veryHigh() {
        XCTAssertEqual(UVLevel(uvIndex: 7.99), .high)
        XCTAssertEqual(UVLevel(uvIndex: 8.00), .veryHigh)
    }

    func test_경계값_11_미만은_veryHigh_11_이상은_extreme() {
        XCTAssertEqual(UVLevel(uvIndex: 10.99), .veryHigh)
        XCTAssertEqual(UVLevel(uvIndex: 11.00), .extreme)
    }

    // MARK: - 음수 UV Index

    func test_음수_uvIndex는_low이다() {
        XCTAssertEqual(UVLevel(uvIndex: -1.0), .low)
    }
}
