//
//  SkinTypePreviewView.swift
//  StopSun
//
//  Created by taeni on 1/21/26.
//

import SwiftUI

struct SkinTypePreviewView: View {
    let skinType: SkinType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Title + Summary
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(skinType.romanNumeral)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(skinType.color)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Text(LocalizedStringKey(skinType.titleKey)
                )
                .font(.headline)
            }
            
            // MARK: - Description
            Text(LocalizedStringKey(skinType.descriptionKey))
                .font(.body)
                .foregroundStyle(.secondary)
            
            // MARK: - MED
            Text(
                LocalizedStringKey(
                    "MED 값 : \(skinType.maxMED, specifier: "%.0f")"
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}


#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(SkinType.allCases) { type in
                SkinTypePreviewView(skinType: type)
            }
        }
        .padding()
    }
}
