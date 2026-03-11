//
//  StopSunTests.swift
//  StopSunTests
//
//  Created by J on 2/2/26.
//
//  ──────────────────────────────────────────────
//  테스트 전략 (참고: https://toss.tech/article/test-strategy-server)
//  ──────────────────────────────────────────────
//
//  1. 도메인 정책 테스트 (단위 테스트)
//     → 비즈니스 규칙 검증, 경계값 중심, 실제 객체 사용
//     → SkinTypeTests, SPFLevelTests, UVLevelTests,
//       WarningLevelTests, SEDCalculatorTests,
//       ExposureSegmentTests, SunscreenApplicationTests,
//       DailyMEDRecordTests
//
//  2. 유스케이스 테스트 (통합 테스트)
//     → 사용자 여정 검증, 여러 계층을 커버하는 소수의 테스트
//     → SyncCoordinatorTests, DashboardViewModelTests
//
//  테스트 더블 전략:
//     - 외부 서비스 (HealthKit, Weather, Location) → Fake 객체
//     - 부수효과 (Notification, LiveActivity)      → Spy 객체
//     - 내부 도메인 (SEDCalculator, SkinType 등)   → 실제 객체
//
