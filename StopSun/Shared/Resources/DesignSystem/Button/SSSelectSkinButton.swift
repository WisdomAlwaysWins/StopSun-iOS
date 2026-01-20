//
//  SSSelectSkinButton.swift
//  StopSun
//
//  Created by taeni on 1/9/26.
//

import SwiftUI

struct SSSelectSkinButton: View {
    private var typeName: String = "1형"
    private var description: String = "매우 하얀 피부, 주근깨 많음\n항상 타거나 화상을 입음, 거의 태닝되지 않음"
    private var skinColor: Color = .skintype00
    private var isSelected: Bool = false
    let action: () -> Void

    // private 프로퍼티 접근을 위한 명시적 생성자
    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(skinColor)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(typeName)
                        .font(.ssFont(.SB2))
                        .foregroundStyle(.text00)
                    
                    Text(description)
                        .font(.ssFont(.R2))
                        .foregroundStyle(.text01)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                }
                Spacer()
            }
            .padding(16)
            .background(isSelected ? .white00 : .white01)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .key00 : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension SSSelectSkinButton {
    @discardableResult
    func typeName(_ text: String) -> Self {
        var view = self
        view.typeName = text
        return view
    }
    
    @discardableResult
    func description(_ text: String) -> Self {
        var view = self
        view.description = text
        return view
    }
    
    @discardableResult
    func skinColor(_ color: Color) -> Self {
        var view = self
        view.skinColor = color
        return view
    }
    
    @discardableResult
    func isSelected(_ selected: Bool) -> Self {
        var view = self
        view.isSelected = selected
        return view
    }
}


// 프리뷰 내에서 상태를 관리하기 위한 컨테이너
struct SSSelectSkinListPreview: View {
    @State private var selectedType: Int = 1 // 현재 선택된 타입
    
    var body: some View {
        VStack(spacing: 12) {
            SSSelectSkinButton {
                selectedType = 1
            }
            .skinColor(.skintype00)
            .typeName("1형")
            .description("매우 하얀 피부, 주근깨 많음\n항상 타거나 화상을 입음, 거의 태닝되지 않음")
            .isSelected(selectedType == 1)
            
            SSSelectSkinButton {
                selectedType = 2
            }
            .skinColor(.skintype01)
            .typeName("2형")
            .description("밝은 피부, 주근깨 조금\n쉽게 타며 태닝이 잘 되지 않음")
            .isSelected(selectedType == 2)
            
            SSSelectSkinButton {
                selectedType = 3
            }
            .skinColor(.skintype02)
            .typeName("3형")
            .description("보통 피부\n가끔 타지만 점차적으로 태닝됨")
            .isSelected(selectedType == 3)
        }
        .padding()
    }
}

#Preview {
    SSSelectSkinListPreview()
}
