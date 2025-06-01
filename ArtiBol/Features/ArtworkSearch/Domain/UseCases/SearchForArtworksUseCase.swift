//
//  SearchForArtworksUseCase.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

final class SearchForArtworksUseCase {
    
    private let client: HTTPClient
    private let baseURL: URL
    private let query: String
    
    init(
        client: HTTPClient,
        baseURL: URL,
        query: String
    ) {
        self.client = client
        self.baseURL = baseURL
        self.query = query
    }
    
    func execute() async throws -> [ArtworkSearchResult] {
        let endPoint = baseURL
            .appendingPathComponent("search")
            .appending(queryItems: [
                .init(name: "q", value: query),
                .init(name: "type", value: "artwork"),
                .init(name: "size", value: "10"),
            ])
        
        let (data, _) = try await client.data(with: URLRequest(url: endPoint))
        return try JSONDecoder().decode(ArtworkSearchResponse.self, from: data).results
    }
}
