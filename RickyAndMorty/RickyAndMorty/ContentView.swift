//
//  ContentView.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var container = AppContainer()

    var body: some View {
        CharacterListView(
            viewModel: container.makeCharacterListViewModel(),
            container: container
        )
    }
}
