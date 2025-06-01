//
//  TokenProvider.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

private struct TokenResponse: Decodable {
    let token: String
    let expiresAt: String
}

protocol TokenProviding: Sendable {
    
    func provideToken() async throws -> String
}

actor TokenProvider: TokenProviding {
    
    static let shared = TokenProvider()
    
    private var token: String?
    private var expiresAt: Date?
    private var refreshTask: Task<String, Error>?
    
    private let baseURL: URL
    private let clientId: String
    private let clientSecret: String
    private let urlSession: URLSession
    private let currentDate: () -> Date
    
    init(
        baseURL: URL = AppConfig.URLS.baseAPIURL,
        clientId: String = AppConfig.Keys.clientID,
        clientSecret: String = AppConfig.Keys.clientSecret,
        urlSession: URLSession = .shared,
        currentDate: @escaping () -> Date = { Date() }
    ) {
        self.baseURL = baseURL
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.urlSession = urlSession
        self.currentDate = currentDate
    }
    
    func provideToken() async throws -> String {
        if let token, let expiry = expiresAt, currentDate() < expiry {
            return token
        }
        
        if let task = refreshTask {
            return try await task.value
        }
        
        let task = Task<String, Error> {
            defer { refreshTask = nil }
            let (newToken, expiryDate) = try await fetchXAPPToken()
            self.token = newToken
            self.expiresAt = expiryDate
            return newToken
        }
        refreshTask = task
        return try await task.value
    }
}

// MARK: - Private -

private extension TokenProvider {
    
    func fetchXAPPToken() async throws -> (token: String, expiryDate: Date) {
        let endPoint = baseURL
            .appendingPathComponent("tokens")
            .appendingPathComponent("xapp_token")
        var request = URLRequest(url: endPoint)
            
        request.httpMethod = "POST"
        let body = [
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        
        let formatter = ISO8601DateFormatter()
        guard let expiryDate = formatter.date(from: tokenResponse.expiresAt) else {
            throw URLError(.cannotParseResponse)
        }
        return (tokenResponse.token, expiryDate)
    }
}
