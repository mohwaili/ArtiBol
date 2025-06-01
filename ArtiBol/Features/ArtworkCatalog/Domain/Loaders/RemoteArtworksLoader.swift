//
//  RemoteArtworksLoader.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

enum RemoteArtworksLoaderError: Error {
    case noMoreArtworks
}

actor RemoteArtworksLoader: ArtworksLoading {
    
    private let client: HTTPClient
    private let baseURL: URL
    
    private let size: Int = 15
    
    private(set) var nextURL: URL?
    
    init(client: HTTPClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }
    
    func load() async throws -> [Artwork] {
        let queryItems: [URLQueryItem] = [
            .init(name: "size", value: String(size))
        ]
        let endPoint = baseURL
            .appendingPathComponent("artworks")
            .appending(queryItems: queryItems)
        return try await fetch(for: endPoint)
    }
    
    func loadMore() async throws -> [Artwork] {
        guard let nextURL else {
            throw RemoteArtworksLoaderError.noMoreArtworks
        }
        return try await fetch(for: nextURL)
    }
}

// MARK: - Private -

private extension RemoteArtworksLoader {
    
    func fetch(for url: URL) async throws -> [Artwork] {
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await client.data(with: request)
            let response = try JSONDecoder().decode(ArtworksResponse.self, from: data)
            self.nextURL = response.nextURL
            return response.artworks
        } catch {
            print(error)
            throw error
        }
    }
}
