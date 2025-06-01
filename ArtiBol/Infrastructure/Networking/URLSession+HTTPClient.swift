//
//  URLSession+HTTPClient.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

extension URLSession: HTTPClient {
    
    func data(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await self.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return (data, httpResponse)
    }
}
