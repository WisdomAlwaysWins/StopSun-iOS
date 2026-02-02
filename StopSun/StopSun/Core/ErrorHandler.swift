//
//  ErrorHandler.swift
//  StopSun
//
//  Created by taeni on 2/2/26.
//

import SwiftUI

/// 에러 핸들러
///
/// 앱 전역에서 발생하는 에러를 처리하고 Alert를 표시합니다.
///
/// ## 사용 예시
/// ```swift
/// // View에서 사용
/// struct ContentView: View {
///     @EnvironmentObject var errorHandler: ErrorHandler
///
///     var body: some View {
///         VStack { ... }
///             .errorAlert(errorHandler)
///     }
/// }
///
/// // 에러 발생 시
/// errorHandler.handle(AppError.network(.noConnection))
/// ```
///
@MainActor
final class ErrorHandler: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Alert 표시 여부
    @Published var showAlert: Bool = false
    
    /// 현재 에러
    @Published private(set) var currentError: AppError?
    
    // MARK: - Alert Properties
    
    /// Alert 제목
    var alertTitle: String {
        currentError?.title ?? L10n.Error.Title.unknown
    }
    
    /// Alert 메시지
    var alertMessage: String {
        currentError?.message ?? L10n.Error.unknown
    }
    
    /// 재시도 가능 여부
    var canRetry: Bool {
        currentError?.isRetryable ?? false
    }
    
    /// 설정 앱 이동 필요 여부
    var requiresSettings: Bool {
        currentError?.requiresSettings ?? false
    }
    
    // MARK: - Retry
    
    /// 재시도 클로저
    private var retryAction: (() async -> Void)?
    
    // MARK: - Handle Error
    
    /// 에러 처리
    ///
    /// - Parameters:
    ///   - error: 발생한 에러
    ///   - retry: 재시도 클로저 (optional)
    func handle(_ error: AppError, retry: (() async -> Void)? = nil) {
        Log.error("에러 발생: \(error.title) - \(error.message)")
        
        currentError = error
        retryAction = retry
        showAlert = true
    }
    
    /// Error 타입을 AppError로 변환하여 처리
    ///
    /// - Parameters:
    ///   - error: Swift Error
    ///   - retry: 재시도 클로저 (optional)
    func handle(_ error: Error, retry: (() async -> Void)? = nil) {
        if let appError = error as? AppError {
            handle(appError, retry: retry)
        } else {
            handle(AppError.unknown(error.localizedDescription), retry: retry)
        }
    }
    
    // MARK: - Actions
    
    /// Alert 닫기
    func dismiss() {
        showAlert = false
        currentError = nil
        retryAction = nil
    }
    
    /// 재시도 실행
    func retry() {
        guard let action = retryAction else { return }
        
        let retryTask = action
        dismiss()
        
        Task {
            await retryTask()
        }
    }
    
    /// 설정 앱 열기
    func openSettings() {
        dismiss()
        
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Error Alert View Modifier

/// 에러 Alert 표시를 위한 View Modifier
struct ErrorAlertModifier: ViewModifier {
    
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorHandler.alertTitle,
                isPresented: $errorHandler.showAlert,
                presenting: errorHandler.currentError
            ) { error in
                // 설정 앱 이동 필요한 경우
                if error.requiresSettings {
                    Button(L10n.Button.openSettings) {
                        errorHandler.openSettings()
                    }
                    Button(L10n.Button.cancel, role: .cancel) {
                        errorHandler.dismiss()
                    }
                }
                // 재시도 가능한 경우
                else if error.isRetryable {
                    Button(L10n.Button.retry) {
                        errorHandler.retry()
                    }
                    Button(L10n.Button.cancel, role: .cancel) {
                        errorHandler.dismiss()
                    }
                }
                // 기본
                else {
                    Button(L10n.Button.confirm, role: .cancel) {
                        errorHandler.dismiss()
                    }
                }
            } message: { _ in
                Text(errorHandler.alertMessage)
            }
    }
}

// MARK: - View Extension

extension View {
    
    /// 에러 Alert 연결
    ///
    /// ```swift
    /// ContentView()
    ///     .errorAlert(errorHandler)
    /// ```
    func errorAlert(_ errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlertModifier(errorHandler: errorHandler))
    }
}
