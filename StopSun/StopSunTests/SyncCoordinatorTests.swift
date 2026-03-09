//
//  SyncCoordinatorTests.swift
//  StopSunTests
//
//  유스케이스 테스트 (통합 테스트)
//
//  SyncCoordinator를 통한 핵심 비즈니스 흐름을 검증합니다.
//  "적지만 많은 계층을 커버하는 통합 테스트"를 지향합니다.
//
//  테스트 더블 전략:
//  - 외부 서비스 (HealthKit, Weather, Location): Fake 객체 (기존 Mock 활용)
//  - 부수효과 서비스 (Notification, LiveActivity): Spy 객체 (호출 기록 검증)
//  - 내부 도메인 로직 (SEDCalculator, SkinType): 실제 객체
//
//  참고: https://toss.tech/article/test-strategy-server
//

@testable import StopSun
import XCTest

@MainActor
final class SyncCoordinatorTests: XCTestCase {

    // MARK: - Properties

    private var sut: SyncCoordinator!
    private var spyNotification: MockNotificationManager!
    private var spyLiveActivity: MockLiveActivityManager!
    private var fakeLocalStorage: MockLocalStorageManager!

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        spyNotification = MockNotificationManager()
        spyLiveActivity = MockLiveActivityManager()
        fakeLocalStorage = MockLocalStorageManager()

        sut = SyncCoordinator(
            healthKit: MockHealthKitManager(),
            weather: MockWeatherManager(),
            location: MockLocationManager(),
            localStorage: fakeLocalStorage,
            notification: spyNotification,
            watchConnectivity: MockWatchConnectivityManager(),
            liveActivity: spyLiveActivity
        )
    }

    override func tearDown() async throws {
        sut = nil
        spyNotification = nil
        spyLiveActivity = nil
        fakeLocalStorage = nil
    }

    // MARK: - 유스케이스: 앱 시작 → 동기화

    func test_startSync_프로필과_날씨를_로드한다() async {
        // Act
        await sut.startSync()

        // Assert - 프로필 로드됨 (MockLocalStorage → .mockUser)
        XCTAssertNotNil(sut.userProfile)
        XCTAssertEqual(sut.userProfile?.skinType, .type3)

        // Assert - 날씨 조회됨 (MockWeatherManager → UV 5.0)
        XCTAssertNotNil(sut.currentWeather)
        XCTAssertEqual(sut.currentWeather?.currentUVIndex, 5.0)
    }

    func test_startSync_완료_후_lastSyncTime이_설정된다() async {
        // Arrange
        XCTAssertNil(sut.lastSyncTime)

        // Act
        await sut.startSync()

        // Assert
        XCTAssertNotNil(sut.lastSyncTime)
        XCTAssertFalse(sut.isSyncing)
    }

    // MARK: - 유스케이스: 선크림 도포
    //
    // 검증 범위: SyncCoordinator → LocalStorage 저장
    //                             → Notification 알림 예약
    //                             → LiveActivity 시작

    func test_applySunscreen_활성_선크림이_설정된다() {
        // Act
        sut.applySunscreen(spf: .spf30)

        // Assert
        XCTAssertNotNil(sut.activeSunscreen)
        XCTAssertEqual(sut.activeSunscreen?.spfLevel, .spf30)
    }

    func test_applySunscreen_히스토리에_저장된다() {
        // Act
        sut.applySunscreen(spf: .spf50)

        // Assert - Fake 스토리지에 기록 확인
        let history = fakeLocalStorage.loadSunscreenHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.spfLevel, .spf50)
    }

    func test_applySunscreen_재도포_알림이_예약된다() {
        // Act
        sut.applySunscreen(spf: .spf30)

        // Assert - Spy 검증: 비동기 알림 예약 대기
        let predicate = NSPredicate { _, _ in
            !self.spyNotification.scheduledReminders.isEmpty
        }
        let exp = expectation(for: predicate, evaluatedWith: nil)
        wait(for: [exp], timeout: 1.0)
    }

    func test_applySunscreen_LiveActivity가_시작된다() {
        // Act
        sut.applySunscreen(spf: .spf50)

        // Assert - Spy 검증: LiveActivity 시작 호출됨
        XCTAssertEqual(spyLiveActivity.startCallCount, 1)
        XCTAssertTrue(spyLiveActivity.isActivityActive)
    }

    func test_applySunscreen_여러번_도포하면_최신_선크림이_활성된다() {
        // Act
        sut.applySunscreen(spf: .spf30)
        sut.applySunscreen(spf: .spf50Plus)

        // Assert - 최신 SPF가 활성
        XCTAssertEqual(sut.activeSunscreen?.spfLevel, .spf50Plus)
        XCTAssertEqual(fakeLocalStorage.loadSunscreenHistory().count, 2)
    }

    // MARK: - 유스케이스: 선크림 중단
    //
    // 검증 범위: SyncCoordinator → Notification 알림 취소
    //                             → LiveActivity 종료

    func test_stopSunscreen_활성_선크림이_해제된다() {
        // Arrange
        sut.applySunscreen(spf: .spf30)
        XCTAssertNotNil(sut.activeSunscreen)

        // Act
        sut.stopSunscreen()

        // Assert
        XCTAssertNil(sut.activeSunscreen)
    }

    func test_stopSunscreen_재도포_알림이_취소된다() {
        // Arrange
        sut.applySunscreen(spf: .spf30)
        let predicate = NSPredicate { _, _ in
            !self.spyNotification.scheduledReminders.isEmpty
        }
        let scheduled = expectation(for: predicate, evaluatedWith: nil)
        wait(for: [scheduled], timeout: 1.0)

        // Act
        sut.stopSunscreen()

        // Assert - Spy 검증: 알림 취소됨
        XCTAssertTrue(spyNotification.scheduledReminders.isEmpty)
    }

    func test_stopSunscreen_LiveActivity가_종료된다() {
        // Arrange
        sut.applySunscreen(spf: .spf30)
        XCTAssertTrue(spyLiveActivity.isActivityActive)

        // Act
        sut.stopSunscreen()

        // Assert - Spy 검증
        XCTAssertEqual(spyLiveActivity.endCallCount, 1)
        XCTAssertFalse(spyLiveActivity.isActivityActive)
    }

    // MARK: - 유스케이스: 피부 타입 / SPF 변경

    func test_updateSkinType_프로필이_업데이트된다() async {
        // Arrange
        await sut.startSync()
        XCTAssertEqual(sut.userProfile?.skinType, .type3)

        // Act
        sut.updateSkinType(.type1)

        // Assert
        XCTAssertEqual(sut.userProfile?.skinType, .type1)
    }

    func test_updateSunScreenSPF_프로필이_업데이트된다() async {
        // Arrange
        await sut.startSync()

        // Act
        sut.updateSunScreenSPF(.spf50Plus)

        // Assert
        XCTAssertEqual(sut.userProfile?.spfLevel, .spf50Plus)
    }

    // MARK: - Computed Properties 통합 테스트
    //
    // SyncCoordinator + SEDCalculator + SkinType + WarningLevel 간의
    // 계산 일관성을 검증합니다. (내부 도메인 로직은 실제 객체 사용)

    func test_todaySEDProgress는_SEDCalculator와_일관된다() {
        // Arrange
        let coordinator = SyncCoordinator.preview(totalSED: 2.0, skinType: .type3)

        // Act & Assert
        let expected = SEDCalculator.progress(currentSED: 2.0, skinType: .type3)
        XCTAssertEqual(coordinator.todaySEDProgress, expected, accuracy: 0.001)
    }

    func test_remainingSED는_SEDCalculator와_일관된다() {
        // Arrange
        let coordinator = SyncCoordinator.preview(totalSED: 2.0, skinType: .type3)

        // Act & Assert
        let expected = SEDCalculator.remainingSED(currentSED: 2.0, skinType: .type3)
        XCTAssertEqual(coordinator.remainingSED, expected, accuracy: 0.001)
    }

    func test_warningLevel은_SED_progress에_따라_결정된다() {
        // Type III: maxSED = 4.0
        let safe = SyncCoordinator.preview(totalSED: 0.5, skinType: .type3)    // 12.5%
        XCTAssertEqual(safe.warningLevel, .safe)

        let caution = SyncCoordinator.preview(totalSED: 1.5, skinType: .type3) // 37.5%
        XCTAssertEqual(caution.warningLevel, .caution)

        let warning = SyncCoordinator.preview(totalSED: 2.5, skinType: .type3) // 62.5%
        XCTAssertEqual(warning.warningLevel, .warning)

        let danger = SyncCoordinator.preview(totalSED: 3.5, skinType: .type3)  // 87.5%
        XCTAssertEqual(danger.warningLevel, .danger)
    }

    func test_같은_SED라도_피부타입에_따라_warningLevel이_다르다() {
        // Arrange - 동일한 2.0 SED
        let type1 = SyncCoordinator.preview(totalSED: 2.0, skinType: .type1) // max 1.5 → 133%
        let type3 = SyncCoordinator.preview(totalSED: 2.0, skinType: .type3) // max 4.0 → 50%
        let type6 = SyncCoordinator.preview(totalSED: 2.0, skinType: .type6) // max 12.0 → 16.7%

        // Assert
        XCTAssertEqual(type1.warningLevel, .danger)
        XCTAssertEqual(type3.warningLevel, .warning)
        XCTAssertEqual(type6.warningLevel, .safe)
    }

    func test_피부타입_변경_시_경고레벨이_재계산된다() {
        // Arrange - Type III (max 4.0), SED 2.0 → 50% → warning
        let coordinator = SyncCoordinator.preview(totalSED: 2.0, skinType: .type3)
        XCTAssertEqual(coordinator.warningLevel, .warning)

        // Act - Type I (max 1.5) → 133% → danger
        coordinator.updateSkinType(.type1)

        // Assert
        XCTAssertEqual(coordinator.warningLevel, .danger)
    }

    func test_minutesUntilMaxSED_선크림_SPF를_반영한다() {
        // Arrange - SPF 없이
        let withoutSPF = SyncCoordinator.preview(totalSED: 2.0, uvIndex: 8.0, skinType: .type3)
        let minutesWithout = withoutSPF.minutesUntilMaxSED()

        // Arrange - SPF 30 적용
        let withSPF = SyncCoordinator.preview(
            totalSED: 2.0,
            uvIndex: 8.0,
            skinType: .type3,
            activeSunscreen: SunscreenApplication(spfLevel: .spf30, appliedAt: Date())
        )
        let minutesWith = withSPF.minutesUntilMaxSED()

        // Assert - SPF 30이면 30배 더 오래 걸림
        XCTAssertGreaterThan(minutesWithout, 0)
        XCTAssertEqual(minutesWith / minutesWithout, 30.0, accuracy: 0.1)
    }

    func test_minutesUntilMaxSED_이미_초과했으면_0이다() {
        // Arrange - Type III (max 4.0), SED 5.0 → 이미 초과
        let coordinator = SyncCoordinator.preview(totalSED: 5.0, skinType: .type3)

        // Act & Assert
        XCTAssertEqual(coordinator.minutesUntilMaxSED(), 0.0)
    }

    func test_currentUVIndex는_날씨의_UV를_반환한다() {
        let coordinator = SyncCoordinator.preview(uvIndex: 8.0)
        XCTAssertEqual(coordinator.currentUVIndex, 8.0)
    }

    func test_날씨_없으면_currentUVIndex는_0이다() {
        // sut은 startSync 전이므로 currentWeather = nil
        XCTAssertEqual(sut.currentUVIndex, 0)
    }
}
