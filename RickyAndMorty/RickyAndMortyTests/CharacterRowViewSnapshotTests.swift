//
//  CharacterRowViewSnapshotTests.swift
//  RickyAndMortyTests
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import RickyAndMorty

@MainActor
final class CharacterRowViewSnapshotTests: XCTestCase {
    /// Records reference PNGs under `__Snapshots__` when missing. Set to `.all` locally to re-record.
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }

    func testCharacterRowAliveNotFavorite() {
        let view = characterRow(status: .alive, isFavorite: false)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits), named: "alive-not-favorite")
    }

    func testCharacterRowDeadFavorite() {
        let view = characterRow(status: .dead, isFavorite: true)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits), named: "dead-favorite")
    }

    private func characterRow(status: CharacterStatus, isFavorite: Bool) -> some View {
        CharacterRowView(
            character: .snapshotRow(status: status, isFavorite: isFavorite),
            toggleFavorite: {}
        )
        .frame(width: 390)
        .padding()
        .background(Color(.systemBackground))
    }
}

private extension Character {
    static func snapshotRow(status: CharacterStatus, isFavorite: Bool) -> Character {
        Character(
            id: 1,
            name: "Rick Sanchez",
            status: status,
            species: "Human",
            type: "",
            gender: "Male",
            origin: "Earth",
            location: "Citadel of Ricks",
            imageURL: "",
            episodeIDs: [1],
            isFavorite: isFavorite
        )
    }
}
