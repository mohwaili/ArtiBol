//
//  AuthenticatedHTTPClient.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

final class AuthenticatedHTTPClient: HTTPClient {
    
    private let session: URLSession
    private let tokenProvider: TokenProviding
    
    init(session: URLSession, tokenProvider: TokenProviding) {
        self.session = session
        self.tokenProvider = tokenProvider
    }
    
    func data(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await perform(request: request)
        
        if response.statusCode == 401 {
            let (retriedData, retriedResponse) = try await perform(request: request)
            guard 200..<300 ~= retriedResponse.statusCode else {
                throw URLError(.userAuthenticationRequired)
            }
            return (retriedData, retriedResponse)
        }
        
        guard 200..<300 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}

// MARK: - Private -

private extension AuthenticatedHTTPClient {
    
    func perform(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let token = try await tokenProvider.provideToken()
        var modifiedRequest = request
        modifiedRequest.setValue(token, forHTTPHeaderField: "X-Xapp-Token")
        let (data, response) = try await session.data(for: modifiedRequest)
        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, httpURLResponse)
    }
}
