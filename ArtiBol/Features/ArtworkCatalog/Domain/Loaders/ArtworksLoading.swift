//
//  ArtworksLoading.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 01/06/2025.
//

import Foundation

protocol ArtworksLoading: Sendable {
    func load() async throws -> [Artwork]
    func loadMore() async throws -> [Artwork]
}
