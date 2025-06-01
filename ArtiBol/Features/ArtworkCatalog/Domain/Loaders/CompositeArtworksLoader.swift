//
//  CompositeArtworksLoader.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

protocol ArtworksStoring {
    
    func store(artworks: [Artwork]) async
    func storeMore(artworks: [Artwork]) async
}

final class CompositeArtworksLoader: ArtworksLoading {
    
    private let remoteLoader: ArtworksLoading
    private let cachedLoader: ArtworksLoading & ArtworksStoring
    
    init(
        remoteLoader: ArtworksLoading,
        cachedLoader: ArtworksLoading & ArtworksStoring
    ) {
        self.remoteLoader = remoteLoader
        self.cachedLoader = cachedLoader
    }
    
    func load() async throws -> [Artwork] {
        do {
            let artworks = try await remoteLoader.load()
            await cachedLoader.store(artworks: artworks)
            return artworks
        } catch {
            let cachedArtworks = try await cachedLoader.load()
            if cachedArtworks.isEmpty {
                throw error
            }
            return cachedArtworks
        }
    }
    
    func loadMore() async throws -> [Artwork] {
        let artworks = try await remoteLoader.loadMore()
        await cachedLoader.storeMore(artworks: artworks)
        return artworks
    }
}
