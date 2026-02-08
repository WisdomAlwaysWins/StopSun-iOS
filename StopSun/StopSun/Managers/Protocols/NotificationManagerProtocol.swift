//
//  NotificationManagerProtocol.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation
import UserNotifications

/// 알림 관리 프로토콜
///
/// 선크림 재도포 알림 및 MED 경고 알림을 관리합니다.
///
/// ## 주요 기능
/// - 알림 권한 요청 및 상태 확인
/// - 재도포 알림 예약/취소/스누즈
/// - MED 경고 알림 발송
/// - 알림 액션 카테고리 등록
///
/// ## 알림 종류
/// | ID | 설명 | 트리거 |
/// |----|------|--------|
/// | reapply | 재도포 알림 | 선크림 도포 2시간 후 |
/// | med_50 | MED 50% 경고 | MED 50% 도달 |
/// | med_80 | MED 80% 경고 | MED 80% 도달 |
/// | med_100 | MED 100% 경고 | MED 100% 도달 |
///
protocol NotificationManagerProtocol: AnyObject {
    
    // MARK: - Properties
    
    /// 권한 허용 여부
    var isAuthorized: Bool { get }
    
    /// 현재 권한 상태
    var authorizationStatus: UNAuthorizationStatus { get async }
    
    // MARK: - Authorization
    
    /// 알림 권한 요청
    ///
    /// - Throws: `AppError.notification(.authorizationDenied)` 권한 거부 시
    func requestAuthorization() async throws
    
    // MARK: - Reapply Reminder
    
    /// 선크림 재도포 알림 예약
    ///
    /// - Parameter date: 알림 시각
    /// - Throws: `AppError.notification(.scheduleFailed)` 예약 실패 시
    func scheduleReapplyReminder(at date: Date) async throws
    
    /// 선크림 재도포 알림 취소
    func cancelReapplyReminder()
    
    /// 스누즈 (15분 후 다시 알림)
    ///
    /// - Throws: `AppError.notification(.scheduleFailed)` 예약 실패 시
    func snoozeReapplyReminder() async throws
    
    // MARK: - MED Warning
    
    /// MED 경고 알림 발송
    ///
    /// - Parameter percentage: 현재 MED 비율 (0.0 ~ 1.0+)
    /// - Note: 50%, 80%, 100% 임계값에서만 알림 발송
    func sendMEDWarning(percentage: Double)
    
    /// MED 경고 발송 이력 초기화
    ///
    /// 날짜가 변경되었을 때 호출하여 중복 방지 이력을 리셋합니다.
    func resetMEDWarningHistory()
    
    // MARK: - Management
    
    /// 모든 알림 취소
    func cancelAllNotifications()
    
    /// 대기 중인 알림 요청 조회
    func getPendingNotifications() async -> [UNNotificationRequest]
    
    // MARK: - Status Refresh
    
    /// 권한 상태를 시스템에서 다시 조회하여 캐시 갱신
    ///
    /// 설정 앱에서 권한 변경 후 앱으로 돌아왔을 때 호출합니다.
    func refreshAuthorizationStatus() async
}

// MARK: - Notification Identifiers

/// 알림 식별자
enum NotificationIdentifier {
    static let reapply = "stopsun.notification.reapply"
    static let med50 = "stopsun.notification.med.50"
    static let med80 = "stopsun.notification.med.80"
    static let med100 = "stopsun.notification.med.100"
}

// MARK: - Notification Category

/// 알림 카테고리 식별자
enum NotificationCategory {
    static let reapply = "stopsun.category.reapply"
    static let medWarning = "stopsun.category.med"
}

// MARK: - Notification Action

/// 알림 액션 식별자
enum NotificationAction {
    static let apply = "stopsun.action.apply"
    static let snooze = "stopsun.action.snooze"
    static let dismiss = "stopsun.action.dismiss"
}
