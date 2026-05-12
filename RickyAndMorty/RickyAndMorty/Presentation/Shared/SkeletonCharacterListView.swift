//
//  SkeletonCharacterListView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import SwiftUI

struct SkeletonCharacterListView: View {
    var body: some View {
        List(0..<8, id: \.self) { _ in
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.quaternary)
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)
                        .frame(width: 180, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)
                        .frame(width: 90, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)
                        .frame(width: 70, height: 18)
                }
            }
            .padding(.vertical, 6)
            .shimmering()
        }
        .listStyle(.plain)
    }
}

