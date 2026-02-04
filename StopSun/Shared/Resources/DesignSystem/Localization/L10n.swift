//
//  L10n.swift
//  StopSun
//
//  Created by taeni on 1/23/26.
//

import Foundation
import SwiftUI

// MARK: - String Extension

extension String {
    
    /// Localizable.xcstrings에서 key로 문자열 가져오기
    static func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
    
    /// Format arguments와 함께 localized string 가져오기
    static func localized(_ key: String, arguments: CVarArg...) -> String {
        let format = String(localized: String.LocalizationValue(key))
        return String(format: format, arguments: arguments)
    }
}

// MARK: - L10n Namespace

enum L10n {
    
    // MARK: - Common Buttons
    
    enum Button {
        static var next: String { .localized("common.button.next") }
        static var cancel: String { .localized("common.button.cancel") }
        static var skip: String { .localized("common.button.skip") }
        static var confirm: String { .localized("common.button.confirm") }
        static var retry: String { .localized("common.button.retry") }
        static var openSettings: String { .localized("common.button.openSettings") }
    }
    
    // MARK: - Onboarding
    
    enum Onboarding {
        static var title: String { .localized("onboarding.title") }
    }
    
    // MARK: - Skin Type
    
    enum SkinType {
        static func title(_ type: Int) -> String {
            .localized("skin.type\(type).title")
        }
        
        static func summary(_ type: Int) -> String {
            .localized("skin.type\(type).summary")
        }
        
        static func description(_ type: Int) -> String {
            .localized("skin.type\(type).description")
        }
        
        static func maxMED(_ value: Double) -> String {
            .localized("skin.maxMED.format", arguments: value)
        }
    }
    
    // MARK: - Notification
    
    enum Notification {
        
        /// 재도포 알림
        enum Reapply {
            static var title: String { .localized("notification.reapply.title") }
            static var body: String { .localized("notification.reapply.body") }
        }
        
        /// MED 경고 알림
        enum MED {
            static var title50: String { .localized("notification.med.title50") }
            static var body50: String { .localized("notification.med.body50") }
            static var title80: String { .localized("notification.med.title80") }
            static var body80: String { .localized("notification.med.body80") }
            static var title100: String { .localized("notification.med.title100") }
            static var body100: String { .localized("notification.med.body100") }
        }
        
        /// 알림 액션
        enum Action {
            static var apply: String { .localized("notification.action.apply") }
            static var snooze: String { .localized("notification.action.snooze") }
            static var dismiss: String { .localized("notification.action.dismiss") }
        }
    }
    
    // MARK: - Error
    
    enum Error {
        
        /// 에러 제목
        enum Title {
            static var healthKit: String { .localized("error.title.healthKit") }
            static var location: String { .localized("error.title.location") }
            static var weather: String { .localized("error.title.weather") }
            static var storage: String { .localized("error.title.storage") }
            static var notification: String { .localized("error.title.notification") }
            static var network: String { .localized("error.title.network") }
            static var watchConnectivity: String { .localized("error.title.watchConnectivity") }
            static var unknown: String { .localized("error.title.unknown") }
        }
        
        /// HealthKit 에러
        enum HealthKit {
            static var notAvailable: String { .localized("error.healthKit.notAvailable") }
            static var authorizationDenied: String { .localized("error.healthKit.authorizationDenied") }
            static var dataFetchFailed: String { .localized("error.healthKit.dataFetchFailed") }
            static var backgroundDeliveryFailed: String { .localized("error.healthKit.backgroundDeliveryFailed") }
        }
        
        /// 위치 에러
        enum Location {
            static var servicesDisabled: String { .localized("error.location.servicesDisabled") }
            static var authorizationDenied: String { .localized("error.location.authorizationDenied") }
            static var locationUnavailable: String { .localized("error.location.locationUnavailable") }
            static var geocodingFailed: String { .localized("error.location.geocodingFailed") }
        }
        
        /// 날씨 에러
        enum Weather {
            static var requestFailed: String { .localized("error.weather.requestFailed") }
            static var parsingFailed: String { .localized("error.weather.parsingFailed") }
            static var invalidLocation: String { .localized("error.weather.invalidLocation") }
            static var quotaExceeded: String { .localized("error.weather.quotaExceeded") }
        }
        
        /// 저장소 에러
        enum Storage {
            static var saveFailed: String { .localized("error.storage.saveFailed") }
            static var loadFailed: String { .localized("error.storage.loadFailed") }
            static var dataCorrupted: String { .localized("error.storage.dataCorrupted") }
            static var insufficientSpace: String { .localized("error.storage.insufficientSpace") }
        }
        
        /// 알림 에러
        enum Notification {
            static var authorizationDenied: String { .localized("error.notification.authorizationDenied") }
            static var scheduleFailed: String { .localized("error.notification.scheduleFailed") }
            static var invalidDate: String { .localized("error.notification.invalidDate") }
        }
        
        /// 네트워크 에러
        enum Network {
            static var noConnection: String { .localized("error.network.noConnection") }
            static var timeout: String { .localized("error.network.timeout") }
            static func serverError(_ code: Int) -> String {
                .localized("error.network.serverError", arguments: code)

    // MARK: - Sunscreen

    enum Sunscreen {

        /// 선크림 효과 상태
        enum Effectiveness {
            static var excellent: String { .localized("sunscreen.effectiveness.excellent") }
            static var good: String { .localized("sunscreen.effectiveness.good") }
            static var weak: String { .localized("sunscreen.effectiveness.weak") }
            static var reapply: String { .localized("sunscreen.effectiveness.reapply") }
        }

        /// 남은 시간 포맷
        enum Time {
            static func hoursMinutes(_ hours: Int, _ minutes: Int) -> String {
                .localized("sunscreen.time.hours_minutes", arguments: hours, minutes)
            }
            static func hours(_ hours: Int) -> String {
                .localized("sunscreen.time.hours", arguments: hours)
            }
            static func minutes(_ minutes: Int) -> String {
                .localized("sunscreen.time.minutes", arguments: minutes)
            }
        }
        
        /// Watch Connectivity 에러
        enum WatchConnectivity {
            static var notReachable: String { .localized("error.watchConnectivity.notReachable") }
            static var sessionInactive: String { .localized("error.watchConnectivity.sessionInactive") }
            static var transferFailed: String { .localized("error.watchConnectivity.transferFailed") }
        }
        
        /// 알 수 없는 에러
        static var unknown: String { .localized("error.unknown") }
            static var expired: String { .localized("sunscreen.time.expired") }
        }
    }
}
