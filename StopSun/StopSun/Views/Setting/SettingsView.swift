//
//  SettingsView.swift
//  StopSun
//
//  Created by taeni on 2/23/26.
//

import SwiftUI

/// 설정 메인 화면
///
/// - 서비스 설정: 알림/위치 권한 → iOS 설정 앱으로 이동
/// - 피부 정보: 피부 타입 (NavigationLink), SPF (Bottom Sheet Wheel Picker)
///
struct SettingsView: View {
    
    // MARK: - Dependencies
    @State private var viewModel: SettingsViewModel
    
    // MARK: - State
    @State private var showSPFPicker = false
    @State private var pendingSPFLevel: SPFLevel = .spf30
    
    init() {
        _viewModel = State(wrappedValue: DIContainer.shared.makeSettingsViewModel())
    }
    
    /// Preview / 테스트용 생성자 — ViewModel 직접 주입
    init(viewModel: SettingsViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    serviceSection
                    divider
                    skinInfoSection
                }
            }
            .background(Color.white00)
            .sheet(isPresented: $showSPFPicker) {
                spfPickerSheet
                    .presentationDetents([.height(280)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        Text(L10n.Settings.title)
            .font(.ssFont(.B2))
            .foregroundStyle(Color.text00)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.bottom, 28)
            .padding(.horizontal, 20)
    }
    
    // MARK: - 서비스 설정 Section
    
    private var serviceSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.Section.service)
                .padding(.bottom, 20)
            
            settingsRow(
                title: L10n.Settings.NotificationSetting.title,
                description: L10n.Settings.NotificationSetting.desc,
                trailing: settingsButton { viewModel.openSettings() }
            )
            
            Spacer().frame(height: 24)
            
            settingsRow(
                title: L10n.Settings.LocationSetting.title,
                description: L10n.Settings.LocationSetting.desc,
                trailing: settingsButton { viewModel.openSettings() }
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 피부 정보 Section
    
    private var skinInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.Section.skin)
                .padding(.bottom, 20)
            
            NavigationLink {
                SkinTypeSettingView(
                    currentSkinType: viewModel.skinType,
                    onComplete: { newType in
                        viewModel.updateSkinType(newType)
                    }
                )
            } label: {
                settingsRow(
                    title: L10n.Settings.SkinTypeSetting.title,
                    description: L10n.Settings.SkinTypeSetting.desc,
                    trailing: navigationValue(viewModel.skinTypeDisplayText)
                )
            }
            .buttonStyle(.plain)
            
            Spacer().frame(height: 24)
            
            // SPF → Bottom Sheet Wheel Picker
            Button {
                pendingSPFLevel = viewModel.spfLevel
                showSPFPicker = true
            } label: {
                settingsRow(
                    title: L10n.Settings.SPFSetting.title,
                    description: L10n.Settings.SPFSetting.desc,
                    trailing: navigationValue(viewModel.spfDisplayText)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - SPF Picker Bottom Sheet
    
    private var spfPickerSheet: some View {
        VStack(spacing: 0) {
            Text(L10n.Settings.SPFSetting.title)
                .font(.ssFont(.SB2))
                .foregroundStyle(Color.text00)
                .padding(.top, 24)
            
            Picker("SPF", selection: $pendingSPFLevel) {
                ForEach(SPFLevel.pickerCases) { level in
                    Text(level.displayTitle).tag(level)
                }
            }
            .pickerStyle(.wheel)
            
            SSButton(L10n.Button.confirm, style: .primary) {
                viewModel.updateSPFLevel(pendingSPFLevel)
                showSPFPicker = false
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Reusable Components
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.ssFont(.R5))
            .foregroundStyle(Color.text03)
    }
    
    private func settingsRow(
        title: String,
        description: String,
        trailing: some View
    ) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.ssFont(.SB2))
                    .foregroundStyle(Color.text00)
                
                Text(description)
                    .font(.ssFont(.R1))
                    .foregroundStyle(Color.text03)
            }
            
            Spacer()
            
            trailing
        }
    }
    
    /// "설정하기 >" 버튼 — iOS 설정 앱으로 이동
    private func settingsButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Text(L10n.Settings.title)
                    .font(.ssFont(.R5))
                    .foregroundStyle(Color.key00)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.key00)
            }
        }
    }
    
    /// "4형 >" 네비게이션 값 표시
    private func navigationValue(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
                .font(.ssFont(.R5))
                .foregroundStyle(Color.key00)
            
            Image(systemName: "chevron.right")
                .font(.ssFont(.R5))
                .foregroundStyle(Color.key00)
        }
    }
    
    /// 섹션 구분선
    private var divider: some View {
        Rectangle()
            .fill(Color.gray01)
            .frame(height: 4)
            .padding(.vertical, 28)
    }
}

// MARK: - Preview

#Preview("Settings") {
    SettingsView(
        viewModel: SettingsViewModel(
            localStorage: MockLocalStorageManager(),
            permissionManager: PermissionManager(
                notification: MockNotificationManager(),
                healthKit: MockHealthKitManager(),
                location: MockLocationManager()
            )
        )
    )
}
