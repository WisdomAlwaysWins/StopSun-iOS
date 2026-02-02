//
//  NotificationManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation
import UserNotifications

/// 알림 관리자
///
/// UNUserNotificationCenter를 사용하여 로컬 알림을 관리합니다.
///
/// ## 주요 기능
/// - 알림 권한 요청
/// - 재도포 알림 예약 (2시간 후)
/// - MED 경고 알림 (50%, 80%, 100%)
/// - 스누즈 (15분)
///
/// ## 알림 카테고리
/// - `reapply`: 재도포 알림 (바르기/스누즈/닫기 액션)
/// - `medWarning`: MED 경고 알림 (닫기 액션)
///
final class NotificationManager: NSObject, NotificationManagerProtocol {
    
    // MARK: - Properties
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    /// 권한 허용 여부 (캐시)
    private var _isAuthorized: Bool = false
    var isAuthorized: Bool { _isAuthorized }
    
    /// MED 경고 발송 이력 (중복 방지)
    private var sentMEDWarnings: Set<Int> = []
    
    /// 스누즈 시간 (분)
    private let snoozeMinutes: Int = 15
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        registerCategories()
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization Status
    
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            let settings = await notificationCenter.notificationSettings()
            return settings.authorizationStatus
        }
    }
    
    private func updateAuthorizationStatus() async {
        let status = await authorizationStatus
        _isAuthorized = (status == .authorized || status == .provisional)
    }
    
    // MARK: - Request Authorization
    
    func requestAuthorization() async throws {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge, .providesAppNotificationSettings]
            )
            
            _isAuthorized = granted
            
            if !granted {
                throw AppError.notification(.authorizationDenied)
            }
            
            Log.info("알림 권한 획득: \(granted)")
        } catch let error as AppError {
            throw error
        } catch {
            Log.error("알림 권한 요청 실패: \(error)")
            throw AppError.notification(.authorizationDenied)
        }
    }
    
    // MARK: - Register Categories
    
    /// 알림 카테고리 및 액션 등록
    private func registerCategories() {
        // 재도포 알림 액션
        let applyAction = UNNotificationAction(
            identifier: NotificationAction.apply,
            title: L10n.Notification.Action.apply,
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze,
            title: L10n.Notification.Action.snooze,
            options: []
        )
        
        let dismissAction = UNNotificationAction(
            identifier: NotificationAction.dismiss,
            title: L10n.Notification.Action.dismiss,
            options: [.destructive]
        )
        
        // 재도포 카테고리
        let reapplyCategory = UNNotificationCategory(
            identifier: NotificationCategory.reapply,
            actions: [applyAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // MED 경고 카테고리
        let medCategory = UNNotificationCategory(
            identifier: NotificationCategory.medWarning,
            actions: [dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([reapplyCategory, medCategory])
        Log.debug("알림 카테고리 등록 완료")
    }
    
    // MARK: - Reapply Reminder
    
    func scheduleReapplyReminder(at date: Date) async throws {
        // 과거 시간 체크
        guard date > Date() else {
            throw AppError.notification(.invalidDate)
        }
        
        // 기존 알림 취소
        cancelReapplyReminder()
        
        // 알림 콘텐츠
        let content = UNMutableNotificationContent()
        content.title = L10n.Notification.Reapply.title
        content.body = L10n.Notification.Reapply.body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.reapply
        content.interruptionLevel = .timeSensitive
        
        // 트리거 (특정 시간)
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        // 요청 생성
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.reapply,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            Log.info("재도포 알림 예약: \(date)")
            
            // TODO: Live Activity 시작
            // await LiveActivityManager.shared.startReapplyActivity(endDate: date)
        } catch {
            Log.error("재도포 알림 예약 실패: \(error)")
            throw AppError.notification(.scheduleFailed)
        }
    }
    
    func cancelReapplyReminder() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.reapply]
        )
        Log.debug("재도포 알림 취소")
        
        // TODO: Live Activity 종료
        // await LiveActivityManager.shared.endReapplyActivity()
    }
    
    func snoozeReapplyReminder() async throws {
        let snoozeDate = Date().addingTimeInterval(TimeInterval(snoozeMinutes * 60))
        try await scheduleReapplyReminder(at: snoozeDate)
        Log.info("재도포 알림 스누즈: \(snoozeMinutes)분 후")
    }
    
    // MARK: - MED Warning
    
    func sendMEDWarning(percentage: Double) {
        // 임계값 결정
        let threshold: Int
        if percentage >= 1.0 {
            threshold = 100
        } else if percentage >= 0.8 {
            threshold = 80
        } else if percentage >= 0.5 {
            threshold = 50
        } else {
            return // 50% 미만은 알림 없음
        }
        
        // 중복 방지
        guard !sentMEDWarnings.contains(threshold) else {
            return
        }
        sentMEDWarnings.insert(threshold)
        
        // 알림 콘텐츠
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = NotificationCategory.medWarning
        content.sound = .default
        
        switch threshold {
        case 50:
            content.title = L10n.Notification.MED.title50
            content.body = L10n.Notification.MED.body50
            content.interruptionLevel = .active
            
        case 80:
            content.title = L10n.Notification.MED.title80
            content.body = L10n.Notification.MED.body80
            content.interruptionLevel = .timeSensitive
            
        case 100:
            content.title = L10n.Notification.MED.title100
            content.body = L10n.Notification.MED.body100
            content.interruptionLevel = .timeSensitive
            
        default:
            return
        }
        
        // 즉시 발송 (trigger = nil)
        let identifier = "stopsun.notification.med.\(threshold)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error {
                Log.error("MED 경고 알림 발송 실패: \(error)")
            } else {
                Log.info("MED 경고 알림 발송: \(threshold)%")
            }
        }
    }
    
    /// MED 경고 이력 초기화 (날짜 변경 시 호출)
    func resetMEDWarningHistory() {
        sentMEDWarnings.removeAll()
        Log.debug("MED 경고 이력 초기화")
    }
    
    // MARK: - Management
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        sentMEDWarnings.removeAll()
        Log.info("모든 알림 취소")
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// 앱이 포그라운드일 때 알림 표시 방식
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // 포그라운드에서도 배너, 사운드 표시
        return [.banner, .sound]
    }
    
    /// 알림 액션 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let actionIdentifier = response.actionIdentifier
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        Log.debug("알림 액션: \(actionIdentifier), 카테고리: \(categoryIdentifier)")
        
        switch actionIdentifier {
        case NotificationAction.apply:
            // 선크림 바르기 → 앱에서 처리
            NotificationCenter.default.post(
                name: .didTapApplySunscreenNotification,
                object: nil
            )
            
        case NotificationAction.snooze:
            // 스누즈
            try? await snoozeReapplyReminder()
            
        case NotificationAction.dismiss,
             UNNotificationDismissActionIdentifier:
            // 닫기 - 아무 동작 없음
            break
            
        case UNNotificationDefaultActionIdentifier:
            // 알림 탭 → 앱 열기
            break
            
        default:
            break
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// 선크림 바르기 알림 액션 탭
    static let didTapApplySunscreenNotification = Notification.Name("didTapApplySunscreenNotification")
}
