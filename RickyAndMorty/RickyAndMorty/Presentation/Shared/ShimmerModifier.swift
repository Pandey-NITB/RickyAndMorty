//
//  ShimmerModifier.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.8

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.45), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(12))
                .offset(x: phase * 260)
                .blendMode(.plusLighter)
            }
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

