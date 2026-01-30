//
//  NotificationManagerProtocol.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// 알림 관리 프로토콜
///
/// 선크림 재도포 알림 및 MED 경고 알림을 관리합니다.
///
protocol NotificationManagerProtocol {
    
    /// 권한 허용 여부
    var isAuthorized: Bool { get }
    
    /// 알림 권한 요청
    func requestAuthorization() async throws
    
    /// 선크림 재도포 알림 예약
    ///
    /// - Parameter date: 알림 시각
    func scheduleReapplyReminder(at date: Date)
    
    /// 선크림 재도포 알림 취소
    func cancelReapplyReminder()
    
    /// MED 경고 알림 발송
    ///
    /// - Parameter percentage: 현재 MED 비율 (0.0 ~ 1.0+)
    func sendMEDWarning(percentage: Double)
    
    /// 모든 알림 취소
    func cancelAllNotifications()
}
