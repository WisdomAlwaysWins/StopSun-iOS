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
        static var `continue`: String { .localized("common.button.continue") }
        static var cancel: String { .localized("common.button.cancel") }
        static var skip: String { .localized("common.button.skip") }
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
}
