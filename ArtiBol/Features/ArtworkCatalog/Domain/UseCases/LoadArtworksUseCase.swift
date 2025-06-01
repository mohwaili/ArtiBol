//
//  LoadArtworksUseCase.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

protocol ArtworksLoading: Sendable {
    func load() async throws -> [Artwork]
    func loadMore() async throws -> [Artwork]
}

final class LoadArtworksUseCase: Sendable {
    
    private let loader: ArtworksLoading
    
    init(loader: ArtworksLoading) {
        self.loader = loader
    }
    
    func load() async throws -> [Artwork] {
        try await loader.load()
    }
    
    func loadMore() async throws -> [Artwork] {
        try await loader.loadMore()
    }
}
