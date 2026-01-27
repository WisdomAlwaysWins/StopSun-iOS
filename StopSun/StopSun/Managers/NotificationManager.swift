//
//  NotificationManager.swift
//  StopSun
//
//  Created by J on 1/27/26.
//

import Foundation

/// 알림 관리자
final class NotificationManager: NotificationManagerProtocol {
    
    var isAuthorized: Bool { false }
    
    func requestAuthorization() async throws {
        // TODO: 구현
    }
    
    func scheduleReapplyReminder(at date: Date) {
        // TODO: 구현
    }
    
    func cancelReapplyReminder() {
        // TODO: 구현
    }
    
    func sendMEDWarning(percentage: Double) {
        // TODO: 구현
    }
    
    func cancelAllNotifications() {
        // TODO: 구현
    }
}
