//
//  StatusBadgeView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import SwiftUI

struct StatusBadgeView: View {
    let status: CharacterStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(status.displayName)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.16))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }

    private var color: Color {
        switch status {
        case .alive:
            return .green
        case .dead:
            return .red
        case .unknown:
            return .gray
        }
    }
}

