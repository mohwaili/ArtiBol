//
//  ArtworkDetailLoader.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

protocol ArtworkDetailLoading: Sendable {
    func load() async throws -> Artwork
}

final class ArtworkDetailLoader: ArtworkDetailLoading {
    
    private let artworkId: String
    private let client: HTTPClient
    private let baseURL: URL
    
    init(
        artworkId: String,
        client: HTTPClient,
        baseURL: URL
    ) {
        self.artworkId = artworkId
        self.client = client
        self.baseURL = baseURL
    }
    
    func load() async throws -> Artwork {
        let endPoint = baseURL
            .appendingPathComponent("artworks")
            .appendingPathComponent(artworkId)
        let request = URLRequest(url: endPoint)
        let (data, _) = try await client.data(with: request)
        return try JSONDecoder().decode(Artwork.self, from: data)
    }
}
