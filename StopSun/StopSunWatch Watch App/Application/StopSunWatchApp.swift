//
//  StopSunWatchApp.swift
//  StopSunWatch Watch App
//
//  Created by taeni on 9/16/25.
//

import SwiftUI
import WatchKit

@main
struct StopSunWatch_Watch_AppApp: App {

    /// WatchAppDelegate를 앱 라이프사이클에 연결
    /// - WKExtensionDelegateAdaptor: SwiftUI 앱에서 UIKit 스타일의 델리게이트를 사용할 수 있게 해줌
    /// - 모든 앱 초기 설정은 WatchAppDelegate.applicationDidFinishLaunching()에서 처리
    @WKExtensionDelegateAdaptor(WatchAppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

