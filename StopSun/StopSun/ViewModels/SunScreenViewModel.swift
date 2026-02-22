//
//  SunScreenViewModel.swift
//  StopSun
//
//  Created by donghee on 1/22/26.
//

import Foundation
import Combine

/// 선크림 관련 View를 위한 ViewModel
@MainActor
@Observable
final class SunScreenViewModel {

    // MARK: - Properties

    private(set) var isActive: Bool = false
    private(set) var remainingMinutes: Int = 0
    private(set) var progressRate: Double = 0.0
    private(set) var effectiveness: Int = 0
    private(set) var applicationTime: String = ""
    private(set) var needsReapplication: Bool = false

    // MARK: - Dependencies

    private let localStorage: any LocalStorageManagerProtocol

    // MARK: - Timer
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    
    init(localStorage: any LocalStorageManagerProtocol) {
        self.localStorage = localStorage
        Log.debug("SunScreenViewModel initialized")

        setupTimer()
        refresh()
    }

    deinit {
        //deinit에서 actor 상태 건드리지 않아야함
//        cancellables.removeAll()
        Log.debug("SunScreenViewModel deinitialized")
    }

    // MARK: - Public Methods

    func applySunScreen() {
        let profile = localStorage.loadUserProfileOrDefault()
        let sunscreen = SunscreenApplication(spfLevel: profile.spfLevel, appliedAt: Date())
        localStorage.saveActiveSunscreen(sunscreen)
        Log.info("Sunscreen applied: SPF \(profile.spfLevel.rawValue)")
        refresh()
    }

    func applySunScreen(withSPF spfLevel: SPFLevel) {
        let sunscreen = SunscreenApplication(spfLevel: spfLevel, appliedAt: Date())
        localStorage.saveActiveSunscreen(sunscreen)
        Log.info("Sunscreen applied with SPF \(spfLevel.rawValue)")
        refresh()
    }

    func removeSunScreen() {
        localStorage.deleteActiveSunscreen()
        Log.info("Sunscreen removed")
        refresh()
    }

    func refresh() {
        updateState()
        Log.debug("SunScreen state refreshed")
    }

    func fetchFormattedRemainingTime() -> String {
        let hours = remainingMinutes / 60
        let minutes = remainingMinutes % 60

        if hours > 0 && minutes > 0 {
            return L10n.Sunscreen.Time.hoursMinutes(hours, minutes)
        } else if hours > 0 {
            return L10n.Sunscreen.Time.hours(hours)
        } else if minutes > 0 {
            return L10n.Sunscreen.Time.minutes(minutes)
        } else {
            return L10n.Sunscreen.Time.expired
        }
    }

    func fetchEffectivenessStatus() -> String {
        switch effectiveness {
        case 80...100: return L10n.Sunscreen.Effectiveness.excellent
        case 50..<80:  return L10n.Sunscreen.Effectiveness.good
        case 1..<50:   return L10n.Sunscreen.Effectiveness.weak
        default:        return L10n.Sunscreen.Effectiveness.reapply
        }
    }

    func fetchEffectivenessColor() -> String {
        switch effectiveness {
        case 80...100: return "key00"
        case 50..<80:  return "key01"
        case 1..<50:   return "text03"
        default:        return "text05"
        }
    }

    // MARK: - Private Methods

    private func setupTimer() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateState()
            }
            .store(in: &cancellables)
    }

    private func updateState() {
        let sunscreen = localStorage.loadActiveSunscreen()
        let now = Date()
        
        isActive = sunscreen?.isActive(at: now) ?? false
        remainingMinutes = localStorage.fetchRemainingMinutes()
        progressRate = calculateProgressRate(sunscreen, at: now)
        effectiveness = Int((1.0 - progressRate) * 100)
        applicationTime = formatApplicationTime(sunscreen)
        needsReapplication = remainingMinutes == 0 || remainingMinutes <= 30
    }

    private func calculateProgressRate(
        _ sunscreen: SunscreenApplication?,
        at now: Date
    ) -> Double {
        guard let sunscreen else { return 1.0 }
        
        let elapsed = now.timeIntervalSince(sunscreen.appliedAt)
        let total = Double(sunscreen.reapplyIntervalMinutes * 60)
        
        return min(max(elapsed / total, 0.0), 1.0)
    }

    private func formatApplicationTime(_ sunscreen: SunscreenApplication?) -> String {
        guard let sunscreen else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: sunscreen.appliedAt)
    }
}
