//
//  SSButton.swift
//  StopSun
//
//  Created by taeni on 1/9/26.
//


import SwiftUI

struct SSButton: View {
    @Binding var isEnabled: Bool

    let title: String
    let action: () -> Void

    var icon: Image?
    var foregroundColor: Color = .white00
    var backgroundColor: Color = .key00
    
    var deactivateForegroundColor: Color = .white01
    var deactivateBackgroundColor: Color = .gray00
    
    var cornerRadius: CGFloat = 8
    var font: Font = .ssFont(.SB2)
    var verticalPadding: CGFloat = 14
    var isInteractive: Bool = true

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    icon
                }

                Text(title)
                    .font(font)
            }
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isEnabled ? foregroundColor : deactivateForegroundColor)
            .background(isEnabled ? backgroundColor : deactivateBackgroundColor)
            .cornerRadius(cornerRadius)
        }
        .disabled(!isEnabled)
    }
}

extension SSButton {

    @discardableResult
    func icon(_ image: Image) -> Self {
        var view = self
        view.icon = image
        return view
    }

    @discardableResult
    func foregroundColor(_ color: Color) -> Self {
        var view = self
        view.foregroundColor = color
        return view
    }

    @discardableResult
    func backgroundColor(_ color: Color) -> Self {
        var view = self
        view.backgroundColor = color
        return view
    }

    @discardableResult
    func font(_ font: Font) -> Self {
        var view = self
        view.font = font
        return view
    }

    @discardableResult
    func verticalPadding(_ value: CGFloat) -> Self {
        var view = self
        view.verticalPadding = value
        return view
    }

    @discardableResult
    func interactive(_ isOn: Bool) -> Self {
        var view = self
        view.isInteractive = isOn
        return view
    }
}

struct SSButtonPreview: View {
    @State private var isEnabled = true

    var body: some View {
        VStack(spacing: 16) {
            SSButton(isEnabled: $isEnabled, title: "기본") {
                print("기본 tap")
            }
            
            SSButton(isEnabled: $isEnabled, title: "계속") {
                print("계속 tap")
            }
            .backgroundColor(.key00)
            .foregroundColor(.white00)
            .font(.ssFont(.SB3))

            Toggle("Enabled", isOn: $isEnabled)
        }
        .padding()
    }
}

#Preview {
    SSButtonPreview()
}
