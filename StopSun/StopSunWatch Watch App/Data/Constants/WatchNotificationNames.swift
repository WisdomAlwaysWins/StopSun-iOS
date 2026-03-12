//
//  WatchNotificationNames.swift
//  StopSunWatch Watch App
//
//  Created by donghee on 3/11/26.
//

import Foundation

// MARK: - Watch Notification Names

extension Notification.Name {

    // MARK: - Sunscreen Actions

    /// 선크림 도포 알림에서 "예" 버튼 탭
    ///
    /// WatchNotificationDelegate에서 sunscreenYes 액션 수신 시 발송
    /// - Note: userInfo에 `WatchNotificationUserInfoKey.notificationIdentifier`, `.timestamp` 포함
    static let watchDidTapSunscreenYes = Notification.Name("watchDidTapSunscreenYes")

    /// 선크림 도포 알림에서 "아니오" 버튼 탭
    ///
    /// WatchNotificationDelegate에서 sunscreenNo 액션 수신 시 발송
    /// - Note: userInfo에 `WatchNotificationUserInfoKey.notificationIdentifier`, `.timestamp` 포함
    static let watchDidTapSunscreenNo = Notification.Name("watchDidTapSunscreenNo")

    // MARK: - Navigation

    /// 알림 본문 탭 (화면 전환용)
    ///
    /// WatchNotificationDelegate에서 기본 알림 탭 수신 시 발송
    /// - Note: userInfo에 `WatchNotificationUserInfoKey.notificationIdentifier` 포함
    static let watchDidTapNotificationBody = Notification.Name("watchDidTapNotificationBody")
}

// MARK: - Watch UserInfo Keys

enum WatchNotificationUserInfoKey {
    /// 알림 요청 식별자
    static let notificationIdentifier = "notificationIdentifier"
    /// 이벤트 발생 시각 (TimeInterval)
    static let timestamp = "timestamp"
}
