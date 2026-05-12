//
//  CharacterRowView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import SwiftUI

struct CharacterRowView: View {
    let character: Character
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            CharacterThumbnailImage(imageURL: character.imageURL)
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                StatusBadgeView(status: character.status)
            }

            Spacer(minLength: 8)

            Button(action: toggleFavorite) {
                Image(systemName: character.isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(character.isFavorite ? .red : .secondary)
                    .accessibilityLabel(character.isFavorite ? "Remove favorite" : "Add favorite")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

private struct CharacterThumbnailImage: View {
    let imageURL: String

    var body: some View {
        CachedRemoteImage(urlString: imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: { isLoading in
            if isLoading {
                Rectangle()
                    .fill(Color.secondary.opacity(0.16))
                    .shimmering()
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.12))
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.secondary)
                .padding(12)
        }
    }
}
