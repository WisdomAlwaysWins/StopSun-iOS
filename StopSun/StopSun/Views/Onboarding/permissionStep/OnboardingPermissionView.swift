//
//  OnboardingPermissionView.swift
//  StopSun
//
//  Created by taeni on 2/8/26.
//

import SwiftUI

/// 온보딩 Step 2: 필요 권한 설정하기
///
/// 3개의 권한 카드를 나열하고, "계속" 버튼 탭 시
/// HealthKit → Location → Notification 순서로 시스템 팝업을 표시합니다.
///
/// ## 권한 요청 정책
/// - 허용/거부 무관하게 Step 3으로 이동합니다.
/// - 핵심 권한(위치)이 거부된 경우 안내 Alert를 표시하되 계속 진행을 허용합니다.
///
struct OnboardingPermissionView: View {
    
    // MARK: - Data Down
    
    let isRequesting: Bool
    @Binding var showPermissionDeniedAlert: Bool
    
    // MARK: - Actions Up
    
    let onContinue: () -> Void
    let onPermissionDeniedContinue: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            titleSection
                .padding(.vertical, 32)
            
            permissionCards
            
            Spacer()
            
            continueButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .alert(
            L10n.Onboarding.Permission.DeniedAlert.title,
            isPresented: $showPermissionDeniedAlert
        ) {
            Button(L10n.Button.openSettings) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(L10n.Onboarding.Permission.DeniedAlert.continueAnyway) {
                onPermissionDeniedContinue()
            }
        } message: {
            Text(L10n.Onboarding.Permission.DeniedAlert.message)
        }
    }
    
    // MARK: - Title
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Onboarding.Permission.title)
                .font(.ssFont(.B2))
                .foregroundStyle(Color.text00)
            
            Text(L10n.Onboarding.Permission.subtitle)
                .font(.ssFont(.R3))
                .foregroundStyle(Color.text01)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Permission Cards
        
    private var permissionCards: some View {
        VStack(spacing: 12) {
            PermissionCardView(
                imageResource: .imgOnboardingHealth,
                title: L10n.Onboarding.Permission.HealthKit.title,
                description: L10n.Onboarding.Permission.HealthKit.description
            )
            
            PermissionCardView(
                imageResource: .imgOnboardingLocation,
                title: L10n.Onboarding.Permission.Location.title,
                description: L10n.Onboarding.Permission.Location.description
            )
            
            PermissionCardView(
                imageResource: .imgOnboardingNotification,
                title: L10n.Onboarding.Permission.Notification.title,
                description: L10n.Onboarding.Permission.Notification.description
            )
        }
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        SSButton(L10n.Onboarding.Permission.continueButton, style: .primary) {
            onContinue()
        }
        .disabled(isRequesting)
        .overlay {
            if isRequesting {
                ProgressView()
                    .tint(.white)
            }
        }
    }
}

// MARK: - Permission Card

/// 개별 권한 카드
private struct PermissionCardView: View {
    
    let imageResource: ImageResource
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageResource)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.ssFont(.SB2))
                    .foregroundStyle(Color.text00)
                
                Text(description)
                    .font(.ssFont(.R1))
                    .foregroundStyle(Color.text01)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white01)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview("Step 2: Permission") {
    @Previewable @State var showAlert = false
    
    OnboardingPermissionView(
        isRequesting: false,
        showPermissionDeniedAlert: $showAlert,
        onContinue: {},
        onPermissionDeniedContinue: {}
    )
}

#Preview("Step 2: Loading") {
    @Previewable @State var showAlert = false
    
    OnboardingPermissionView(
        isRequesting: true,
        showPermissionDeniedAlert: $showAlert,
        onContinue: {},
        onPermissionDeniedContinue: {}
    )
}
