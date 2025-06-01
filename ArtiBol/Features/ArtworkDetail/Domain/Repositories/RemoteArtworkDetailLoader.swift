//
//  RemoteArtworkDetailLoader.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

final class RemoteArtworkDetailLoader: ArtworkDetailLoading {
    
    private let client: HTTPClient
    private let baseURL: URL
    
    init(client: HTTPClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }
    
    func load(id: String) async throws -> ArtworkDetail {
        let endPoint = baseURL
            .appendingPathComponent("artworks")
            .appendingPathComponent(id)
        let request = URLRequest(url: endPoint)
        let (data, _) = try await client.data(with: request)
        return try JSONDecoder().decode(ArtworkDetail.self, from: data)
    }
}
