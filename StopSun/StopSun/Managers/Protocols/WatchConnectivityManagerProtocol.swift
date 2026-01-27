//
//  WatchConnectivityManagerProtocol.swift
//  StopSun
//
//  Created by J on 1/26/26.
//

import Foundation

/// Watch Connectivity 관리 프로토콜
///
/// iPhone ↔ Apple Watch 간 데이터 동기화를 관리합니다.
///
/// ## 동기화 데이터
/// - 사용자 프로필
/// - 선크림 도포 기록
/// - 현재 MED 상태
///
protocol WatchConnectivityManagerProtocol {

    /// Watch 연결 상태
    var isReachable: Bool { get }
    
    /// Watch Connectivity 세션 활성화
    func activate()
    
    /// 사용자 프로필 전송
    func sendUserProfile(_ profile: UserProfile)
    
    /// 선크림 도포 기록 전송
    func sendSunscreenApplication(_ application: SunscreenApplication)
    
    /// 현재 MED 상태 전송
    ///
    /// - Parameters:
    ///   - totalSED: 누적 SED
    ///   - maxMED: 최대 MED (피부 타입 기준)
    func sendMEDStatus(totalSED: Double, maxMED: Double)
}
