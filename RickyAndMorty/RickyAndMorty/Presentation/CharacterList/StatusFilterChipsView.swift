//
//  StatusFilterChipsView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//



import SwiftUI

struct StatusFilterChipsView: View {
    let selectedStatus: CharacterStatus?
    let onSelect: (CharacterStatus?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                StatusChip(title: "All", isSelected: selectedStatus == nil) {
                    onSelect(nil)
                }

                ForEach(CharacterStatus.allCases, id: \.self) { status in
                    StatusChip(title: status.displayName, isSelected: selectedStatus == status) {
                        onSelect(status)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

private struct StatusChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

