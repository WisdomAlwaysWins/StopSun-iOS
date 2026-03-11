//
//  SkinTypeTests.swift
//  StopSunTests
//
//  TDD 방식으로 작성된 SkinType 테스트
//  참고: https://tech.kakaopay.com/post/implementing-tdd-in-practical-applications/
//

@testable import StopSun
import XCTest

final class SkinTypeTests: XCTestCase {

    // MARK: - maxDailyMEDinSED Tests

    func test_maxDailyMEDinSED_모든_타입() {
        XCTAssertEqual(SkinType.type1.maxDailyMEDinSED, 1.5)
        XCTAssertEqual(SkinType.type2.maxDailyMEDinSED, 3.0)
        XCTAssertEqual(SkinType.type3.maxDailyMEDinSED, 4.0)
        XCTAssertEqual(SkinType.type4.maxDailyMEDinSED, 5.0)
        XCTAssertEqual(SkinType.type5.maxDailyMEDinSED, 7.0)
        XCTAssertEqual(SkinType.type6.maxDailyMEDinSED, 12.0)
    }

    func test_타입_번호가_높을수록_maxDailyMEDinSED가_크다() {
        let allTypes = SkinType.allCases.sorted { $0.rawValue < $1.rawValue }

        for i in 0..<(allTypes.count - 1) {
            XCTAssertTrue(
                allTypes[i].maxDailyMEDinSED < allTypes[i + 1].maxDailyMEDinSED,
                "\(allTypes[i])의 maxDailyMEDinSED가 \(allTypes[i + 1])보다 작아야 함"
            )
        }
    }

    // MARK: - maxMED Tests

    func test_maxMED_모든_타입() {
        XCTAssertEqual(SkinType.type1.maxMED, 150)
        XCTAssertEqual(SkinType.type2.maxMED, 300)
        XCTAssertEqual(SkinType.type3.maxMED, 400)
        XCTAssertEqual(SkinType.type4.maxMED, 500)
        XCTAssertEqual(SkinType.type5.maxMED, 700)
        XCTAssertEqual(SkinType.type6.maxMED, 1200)
    }

    func test_maxMED는_maxDailyMEDinSED의_100배이다() {
        // maxMED(J/m^2) = maxDailyMEDinSED(SED) * 100(joulesPerSED)
        for skinType in SkinType.allCases {
            XCTAssertEqual(
                skinType.maxMED,
                skinType.maxDailyMEDinSED * 100,
                accuracy: 0.01,
                "\(skinType)의 maxMED와 maxDailyMEDinSED * 100이 불일치"
            )
        }
    }

    // MARK: - romanNumeral Tests

    func test_romanNumeral_모든_타입() {
        XCTAssertEqual(SkinType.type1.romanNumeral, "I")
        XCTAssertEqual(SkinType.type2.romanNumeral, "II")
        XCTAssertEqual(SkinType.type3.romanNumeral, "III")
        XCTAssertEqual(SkinType.type4.romanNumeral, "IV")
        XCTAssertEqual(SkinType.type5.romanNumeral, "V")
        XCTAssertEqual(SkinType.type6.romanNumeral, "VI")
    }

    // MARK: - rawValue & id Tests

    func test_rawValue는_1부터_6이다() {
        let rawValues = SkinType.allCases.map { $0.rawValue }
        XCTAssertEqual(rawValues, [1, 2, 3, 4, 5, 6])
    }

    func test_id는_rawValue와_같다() {
        for skinType in SkinType.allCases {
            XCTAssertEqual(skinType.id, skinType.rawValue)
        }
    }

    // MARK: - allCases Tests

    func test_총_6개_피부타입이_존재한다() {
        XCTAssertEqual(SkinType.allCases.count, 6)
    }
}
