//
//  CharacterListView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import SwiftUI

struct CharacterListView: View {
    @StateObject private var viewModel: CharacterListViewModel
    private let container: AppContainer

    init(viewModel: CharacterListViewModel, container: AppContainer) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                StatusFilterChipsView(
                    selectedStatus: viewModel.selectedStatus,
                    onSelect: viewModel.setStatusFilter
                )
                .background(Color(.systemBackground))

                Divider()

                content
            }
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search by name")
            .alert("Something went wrong", isPresented: errorAlertBinding) {
                Button("Retry") {
                    viewModel.loadFirstPage()
                }
                Button("Dismiss", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isInitialLoading {
            SkeletonCharacterListView()
        } else if viewModel.characters.isEmpty {
            EmptyCharactersView()
        } else {
            List {
                ForEach(viewModel.characters) { character in
                    NavigationLink(
                        destination: CharacterDetailView(
                            viewModel: container.makeCharacterDetailViewModel(character: character),
                            onFavoriteChange: viewModel.applyFavoriteStatus
                        )
                    ) {
                        CharacterRowView(
                            character: character,
                            toggleFavorite: {
                                viewModel.toggleFavorite(character: character)
                            }
                        )
                    }
                    .onAppear {
                        viewModel.loadNextPageIfNeeded(currentCharacter: character)
                    }
                }

                if viewModel.isLoadingNextPage {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
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

private struct EmptyCharactersView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No characters found")
                .font(.headline)
            Text("Try a different search or status filter.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
