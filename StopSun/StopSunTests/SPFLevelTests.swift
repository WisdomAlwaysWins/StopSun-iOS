//
//  SPFLevelTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 SPFLevel 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class SPFLevelTests: XCTestCase {

    // MARK: - protectionFactor Tests

    func test_protectionFactor_none은_1을_반환한다() {
        // Arrange
        let spf = SPFLevel.none

        // Act
        let factor = spf.protectionFactor

        // Assert
        XCTAssertEqual(factor, 1.0)
    }

    func test_protectionFactor_spf30은_30을_반환한다() {
        let factor = SPFLevel.spf30.protectionFactor
        XCTAssertEqual(factor, 30.0)
    }

    func test_protectionFactor_spf50Plus는_55를_반환한다() {
        let factor = SPFLevel.spf50Plus.protectionFactor
        XCTAssertEqual(factor, 55.0)
    }

    func test_protectionFactor_rawValue와_일치한다() {
        for spf in SPFLevel.allCases {
            XCTAssertEqual(spf.protectionFactor, Double(spf.rawValue),
                           "\(spf)의 protectionFactor가 rawValue와 불일치")
        }
    }

    // MARK: - uvBlockingPercentage Tests

    func test_uvBlockingPercentage_none은_0퍼센트이다() {
        let percentage = SPFLevel.none.uvBlockingPercentage
        XCTAssertEqual(percentage, 0.0)
    }

    func test_uvBlockingPercentage_spf30은_약_96_7퍼센트이다() {
        // (1 - 1/30) * 100 = 96.67%
        let percentage = SPFLevel.spf30.uvBlockingPercentage
        XCTAssertEqual(percentage, 96.67, accuracy: 0.01)
    }

    func test_uvBlockingPercentage_spf50은_98퍼센트이다() {
        // (1 - 1/50) * 100 = 98%
        let percentage = SPFLevel.spf50.uvBlockingPercentage
        XCTAssertEqual(percentage, 98.0, accuracy: 0.01)
    }

    func test_uvBlockingPercentage_spf가_높을수록_차단율이_높다() {
        let spf10 = SPFLevel.spf10.uvBlockingPercentage
        let spf30 = SPFLevel.spf30.uvBlockingPercentage
        let spf50 = SPFLevel.spf50.uvBlockingPercentage

        XCTAssertTrue(spf10 < spf30)
        XCTAssertTrue(spf30 < spf50)
    }

    // MARK: - recommendedReapplicationMinutes Tests

    func test_재도포시간_none은_0분이다() {
        XCTAssertEqual(SPFLevel.none.recommendedReapplicationMinutes, 0)
    }

    func test_재도포시간_선크림은_120분이다() {
        for spf in SPFLevel.allCases where spf != .none {
            XCTAssertEqual(spf.recommendedReapplicationMinutes, 120,
                           "\(spf)의 재도포 시간이 120분이 아님")
        }
    }

    // MARK: - pickerCases Tests

    func test_pickerCases는_none을_포함하지_않는다() {
        XCTAssertFalse(SPFLevel.pickerCases.contains(.none))
    }

    func test_pickerCases는_none을_제외한_모든_케이스를_포함한다() {
        let expected = SPFLevel.allCases.filter { $0 != .none }
        XCTAssertEqual(SPFLevel.pickerCases, expected)
    }

    // MARK: - id Tests

    func test_id는_rawValue와_같다() {
        for spf in SPFLevel.allCases {
            XCTAssertEqual(spf.id, spf.rawValue)
        }
    }
}
