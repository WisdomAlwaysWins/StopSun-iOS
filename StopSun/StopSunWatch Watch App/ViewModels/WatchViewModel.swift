//
//  WatchViewModel.swift
//  StopSunWatch Watch App
//
//  Created by donghee on 2/21/26.
//

import SwiftUI
import Combine

/// Watch 화면 상태 관리 ViewModel
///
/// iPhone에서 수신한 대시보드 데이터를 관리하고 UI에 제공합니다.
///
/// ## 데이터 흐름
/// 1. 앱 실행 시 캐시된 Application Context에서 초기 데이터 로드
/// 2. iPhone에 대시보드 동기화 요청
/// 3. 실시간 메시지 및 Application Context 수신으로 업데이트
///
@MainActor
class WatchViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var isPhoneConnected: Bool = false
    @Published var currentUVIndex: Double = 0.0
    @Published var temperature: Double = 0.0
    @Published var cityName: String = "대기 중..."
    @Published var todayTotalSED: Double = 0.0
    @Published var maxSED: Double = 0.0
    @Published var warningLevel: String = "safe"
    @Published var sunscreenSPF: Int?
    @Published var sunscreenAppliedAt: Date?

    /// 마지막 동기화 성공 시각 (nil이면 아직 동기화 안 됨)
    @Published var lastSyncTime: Date?

    /// 동기화 실패 여부
    @Published var syncFailed: Bool = false

    // MARK: - Private Properties

    private let sessionManager = WatchSessionManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Formatted Display Properties

    /// 기온 표시 (소수점 1자리)
    var temperatureText: String {
        String(format: "%.1f°", temperature)
    }

    /// UV Index 표시 (소수점 1자리)
    var uvIndexText: String {
        String(format: "%.1f", currentUVIndex)
    }

    /// 누적 SED 표시 (소수점 2자리)
    var totalSEDText: String {
        String(format: "%.2f", todayTotalSED)
    }

    /// 최대 SED 표시 (소수점 1자리)
    var maxSEDText: String {
        String(format: "%.1f", maxSED)
    }

    /// 마지막 동기화 시각 표시
    var lastSyncText: String {
        guard let time = lastSyncTime else { return "동기화 안 됨" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "마지막 동기화 \(formatter.string(from: time))"
    }

    // MARK: - Computed Properties

    /// SED 진행률 (0.0 ~ 1.0+)
    var sedProgress: Double {
        guard maxSED > 0 else { return 0 }
        return todayTotalSED / maxSED
    }

    /// 경고 레벨 한글 표시
    var warningLevelTitle: String {
        switch warningLevel {
        case "safe": return "안전"
        case "caution": return "주의"
        case "warning": return "경고"
        case "danger": return "위험"
        default: return "알 수 없음"
        }
    }

    /// 경고 레벨 색상
    var warningLevelColor: Color {
        switch warningLevel {
        case "safe": return .green
        case "caution": return .yellow
        case "warning": return .orange
        case "danger": return .red
        default: return .gray
        }
    }

    /// 선크림 도포 상태 텍스트
    var sunscreenStatusText: String {
        guard let spf = sunscreenSPF else { return "미도포" }
        return "SPF \(spf)"
    }

    // MARK: - Initialization

    init() {
        setupWatchConnectivity()
        observeReachability()
        loadCachedData()
    }

    // MARK: - Setup Methods

    private func setupWatchConnectivity() {
        // 즉시 메시지 수신 콜백
        sessionManager.onMessageReceived = { [weak self] message in
            self?.handleMessageFromPhone(message)
        }

        // UserInfo 수신 콜백
        sessionManager.onUserInfoReceived = { [weak self] userInfo in
            self?.handleUserInfoFromPhone(userInfo)
        }

        // Application Context 수신 콜백
        sessionManager.onApplicationContextReceived = { [weak self] context in
            self?.handleDashboardData(context)
        }
    }

    private func observeReachability() {
        sessionManager.$isReachable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReachable in
                self?.isPhoneConnected = isReachable
                print("[Watch] iPhone 연결 상태: \(isReachable)")
            }
            .store(in: &cancellables)
    }

    /// 캐시된 Application Context에서 초기 데이터 로드
    private func loadCachedData() {
        guard let cached = sessionManager.loadCachedApplicationContext() else { return }
        handleDashboardData(cached)
        print("[Watch] 캐시 데이터로 초기 화면 구성 완료")
    }

    // MARK: - Public Methods

    /// iPhone에 대시보드 동기화 요청
    func requestDashboardSync() {
        syncFailed = false

        sessionManager.sendMessage(
            ["request_dashboard_sync": true, "timestamp": Date().timeIntervalSince1970],
            replyHandler: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.syncFailed = false
                    print("[Watch] 동기화 요청 전달 완료")
                }
            },
            errorHandler: { [weak self] error in
                DispatchQueue.main.async {
                    self?.syncFailed = true
                    print("[Watch] 동기화 요청 실패: \(error.localizedDescription)")
                }
            }
        )
    }

    // MARK: - Message Handling

    private func handleMessageFromPhone(_ message: [String: Any]) {
        print("[Watch] iPhone 메시지 처리: \(message["type"] as? String ?? "unknown")")

        if message["type"] as? String == "dashboard_data" {
            handleDashboardData(message)
        }

        if message["type"] as? String == "sunscreen_application" {
            handleSunscreenData(message)
        }

        if message["type"] as? String == "med_status" {
            handleMEDStatus(message)
        }
    }

    private func handleUserInfoFromPhone(_ userInfo: [String: Any]) {
        print("[Watch] iPhone UserInfo 처리: \(userInfo["type"] as? String ?? "unknown")")

        if userInfo["type"] as? String == "user_profile" {
            handleUserProfile(userInfo)
        }
    }

    // MARK: - Data Parsing

    private func handleDashboardData(_ data: [String: Any]) {
        if let uvIndex = data["uvIndex"] as? Double {
            currentUVIndex = uvIndex
        }
        if let temp = data["temperature"] as? Double {
            temperature = temp
        }
        if let city = data["cityName"] as? String {
            cityName = city
        }
        if let sed = data["totalSED"] as? Double {
            todayTotalSED = sed
        }
        if let max = data["maxSED"] as? Double {
            maxSED = max
        }
        if let level = data["warningLevel"] as? String {
            warningLevel = level
        }

        sunscreenSPF = data["sunscreenSPF"] as? Int
        if let appliedAt = data["sunscreenAppliedAt"] as? Double {
            sunscreenAppliedAt = Date(timeIntervalSince1970: appliedAt)
        } else {
            sunscreenAppliedAt = nil
        }

        // 동기화 성공 시각 기록
        lastSyncTime = Date()
        syncFailed = false
    }

    private func handleSunscreenData(_ data: [String: Any]) {
        if let spf = data["spfLevel"] as? Int {
            sunscreenSPF = spf
        }
        if let appliedAt = data["appliedAt"] as? Double {
            sunscreenAppliedAt = Date(timeIntervalSince1970: appliedAt)
        }
    }

    private func handleMEDStatus(_ data: [String: Any]) {
        if let sed = data["totalSED"] as? Double {
            todayTotalSED = sed
        }
        if let max = data["maxMED"] as? Double {
            maxSED = max
        }
    }

    private func handleUserProfile(_ data: [String: Any]) {
        // 향후 피부 타입 표시 등에 활용
        if let skinType = data["skinType"] as? Int {
            print("[Watch] 사용자 피부 타입 수신: \(skinType)")
        }
    }
}
