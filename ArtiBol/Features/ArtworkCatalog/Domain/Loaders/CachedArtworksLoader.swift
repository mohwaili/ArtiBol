//
//  CachedArtworksLoader.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

actor CachedArtworksLoader: ArtworksLoading {
    
    private(set) var artworks: [Artwork] = []
    
    func load() throws -> [Artwork] {
        return artworks
    }
    
    func loadMore() throws -> [Artwork] {
        []
    }
}

extension CachedArtworksLoader: ArtworksStoring {
    
    func store(artworks: [Artwork]) {
        self.artworks = artworks
    }
    
    func storeMore(artworks: [Artwork]) {
        self.artworks.append(contentsOf: artworks)
    }
}
