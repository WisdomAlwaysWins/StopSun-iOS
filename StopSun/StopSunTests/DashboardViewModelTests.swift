//
//  DashboardViewModelTests.swift
//  StopSunTests
//
//  유스케이스 테스트 - DashboardViewModel의 데이터 변환 검증
//
//  SyncCoordinator → ViewModel → View 계층의 데이터 흐름을 검증합니다.
//  SyncCoordinator.preview()를 통해 다양한 초기 상태를 설정하고,
//  ViewModel이 올바르게 변환하는지 확인합니다.
//
//  참고: https://toss.tech/article/test-strategy-server
//

@testable import StopSun
import XCTest

@MainActor
final class DashboardViewModelTests: XCTestCase {

    // MARK: - MED 변환 테스트
    //
    // SyncCoordinator(SED) → DashboardViewModel(J/m²) 변환 검증

    func test_currentMED는_SED에_joulesPerSED를_곱한_값이다() {
        // Arrange - totalSED = 2.0
        let coordinator = SyncCoordinator.preview(totalSED: 2.0)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Act & Assert - 2.0 SED × 100 joulesPerSED = 200 J/m²
        XCTAssertEqual(sut.currentMED, 200.0, accuracy: 0.01)
    }

    func test_maxMED는_피부타입별_maxMED와_일치한다() {
        // Arrange
        let coordinator = SyncCoordinator.preview(skinType: .type3)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Assert - Type III: maxMED = 400 J/m²
        XCTAssertEqual(sut.maxMED, SkinType.type3.maxMED, accuracy: 0.01)
    }

    func test_medPercentage는_progress의_100배이다() {
        // Arrange - Type III (max 4.0), SED 2.0 → progress 50%
        let coordinator = SyncCoordinator.preview(totalSED: 2.0, skinType: .type3)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Act & Assert
        XCTAssertEqual(sut.medPercentage, 50.0, accuracy: 0.1)
    }

    func test_warningLevel은_SyncCoordinator와_동일하다() {
        // Arrange
        let coordinator = SyncCoordinator.preview(totalSED: 2.5, skinType: .type3)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Assert - 62.5% → warning
        XCTAssertEqual(sut.warningLevel, coordinator.warningLevel)
        XCTAssertEqual(sut.warningLevel, .warning)
    }

    // MARK: - 날씨 데이터 변환 테스트

    /// uvIndex는 Int() 변환으로 내림 처리됩니다.
    /// 기획 의도: UV Index는 정수 단위로 표시하며, 소수점 이하는 버립니다.
    func test_uvIndex는_Int변환으로_내림_처리된다() {
        let coordinator = SyncCoordinator.preview(uvIndex: 7.9)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Int(7.9) = 7 (내림, 반올림 아님)
        XCTAssertEqual(sut.uvIndex, 7)
    }

    func test_uvIndex_정수값은_그대로_유지된다() {
        let coordinator = SyncCoordinator.preview(uvIndex: 8.0)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.uvIndex, 8)
    }

    func test_temperature는_현재_기온을_반환한다() {
        let coordinator = SyncCoordinator.preview(temperature: 28.5)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.temperature, 28.5, accuracy: 0.1)
    }

    func test_locationName은_cityName을_반환한다() {
        let coordinator = SyncCoordinator.preview(cityName: "포항시")
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.locationName, "포항시")
    }

    // MARK: - 선크림 타이머 테스트

    func test_isTimerActive_선크림_없으면_false() {
        let coordinator = SyncCoordinator.preview()
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertFalse(sut.isTimerActive)
    }

    func test_isTimerActive_활성_선크림이면_true() {
        let sunscreen = SunscreenApplication(spfLevel: .spf30, appliedAt: Date())
        let coordinator = SyncCoordinator.preview(activeSunscreen: sunscreen)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertTrue(sut.isTimerActive)
    }

    func test_isTimerActive_만료된_선크림이면_false() {
        // 2시간 전 도포 → 만료됨
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: Date().addingTimeInterval(-7200),
            reapplyIntervalMinutes: 120
        )
        let coordinator = SyncCoordinator.preview(activeSunscreen: sunscreen)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertFalse(sut.isTimerActive)
    }

    func test_timerRemaining_선크림_없으면_0000() {
        let coordinator = SyncCoordinator.preview()
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.timerRemaining(at: Date()), "00:00")
    }

    func test_timerRemaining_도포_직후_약_2시간_표시() {
        // Arrange - 방금 도포, 120분 만료
        let now = Date()
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: now,
            reapplyIntervalMinutes: 120
        )
        let coordinator = SyncCoordinator.preview(activeSunscreen: sunscreen)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Act - 도포 1초 후 시점
        let remaining = sut.timerRemaining(at: now.addingTimeInterval(1))

        // Assert - "1:59:59" (시:분:초)
        XCTAssertEqual(remaining, "1:59:59")
    }

    func test_timerRemaining_1시간_미만이면_분초_포맷() {
        // Arrange - 61분 전 도포, 120분 만료 → 59분 남음
        let now = Date()
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: now.addingTimeInterval(-61 * 60),
            reapplyIntervalMinutes: 120
        )
        let coordinator = SyncCoordinator.preview(activeSunscreen: sunscreen)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        // Act
        let remaining = sut.timerRemaining(at: now)

        // Assert - "59:00" (분:초, 시 없음)
        XCTAssertEqual(remaining, "59:00")
    }

    func test_timerRemaining_만료되면_0000() {
        // 2시간 전 도포 → 만료
        let now = Date()
        let sunscreen = SunscreenApplication(
            spfLevel: .spf30,
            appliedAt: now.addingTimeInterval(-7200),
            reapplyIntervalMinutes: 120
        )
        let coordinator = SyncCoordinator.preview(activeSunscreen: sunscreen)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.timerRemaining(at: now), "00:00")
    }

    // MARK: - 경계값 테스트

    func test_SED가_0이면_MED_관련_값이_모두_0이다() {
        let coordinator = SyncCoordinator.preview(totalSED: 0)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.currentMED, 0)
        XCTAssertEqual(sut.medPercentage, 0)
    }

    func test_SED가_maxSED를_초과하면_percentage가_100을_넘는다() {
        // Type III (max 4.0), SED 5.0 → 125%
        let coordinator = SyncCoordinator.preview(totalSED: 5.0, skinType: .type3)
        let sut = DashboardViewModel(syncCoordinator: coordinator)

        XCTAssertEqual(sut.medPercentage, 125.0, accuracy: 0.1)
    }
}
