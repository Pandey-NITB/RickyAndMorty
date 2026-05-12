//
//  CharacterDetailView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel
    private let onFavoriteChange: (Int, Bool) -> Void

    init(
        viewModel: CharacterDetailViewModel,
        onFavoriteChange: @escaping (Int, Bool) -> Void = { _, _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFavoriteChange = onFavoriteChange
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                details
                episodes
            }
            .padding()
        }
        .navigationTitle(viewModel.character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                viewModel.toggleFavorite(onChange: onFavoriteChange)
            } label: {
                Image(systemName: viewModel.character.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(viewModel.character.isFavorite ? .red : .primary)
            }
            .accessibilityLabel(viewModel.character.isFavorite ? "Remove favorite" : "Add favorite")
        }
        .onAppear {
            viewModel.onAppear()
        }
        .alert("Unable to load episodes", isPresented: errorAlertBinding) {
            Button("Retry") {
                Task { await viewModel.loadEpisodes() }
            }
            Button("Dismiss", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            CharacterDetailImage(imageURL: viewModel.character.imageURL)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.character.name)
                        .font(.largeTitle.bold())
                    StatusBadgeView(status: viewModel.character.status)
                }
                Spacer()
            }
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile")
                .font(.title2.bold())

            DetailRow(title: "Species", value: viewModel.character.species)
            if !viewModel.character.type.isEmpty {
                DetailRow(title: "Type", value: viewModel.character.type)
            }
            DetailRow(title: "Gender", value: viewModel.character.gender)
            DetailRow(title: "Origin", value: viewModel.character.origin)
            DetailRow(title: "Location", value: viewModel.character.location)
        }
    }

    private var episodes: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodes")
                .font(.title2.bold())

            if viewModel.isLoadingEpisodes {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .frame(height: 52)
                        .shimmering()
                }
            } else {
                ForEach(viewModel.episodes) { episode in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(episode.name)
                            .font(.headline)
                        Text("\(episode.episodeCode) • \(episode.airDate)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding {
            viewModel.errorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.clearError()
            }
        }
    }
}

private struct CharacterDetailImage: View {
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
                .scaledToFit()
                .foregroundStyle(.secondary)
                .padding(72)
        }
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.body)
    }
}
