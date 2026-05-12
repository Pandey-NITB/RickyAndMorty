//
//  PaginatedCharacters.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//



struct PaginatedCharacters: Equatable, Sendable {
    let characters: [Character]
    let currentPage: Int
    let hasNextPage: Bool
}

