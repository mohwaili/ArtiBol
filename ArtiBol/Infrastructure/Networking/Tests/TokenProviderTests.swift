//
//  TokenProviderTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation
import Testing
@testable import ArtiBol

@Suite(.serialized)
class TokenProviderTests {
    
    private let session: URLSession
    private let baseURL = URL(string: "https://artibol.com/api")!
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        self.session = URLSession(configuration: config)
    }
    
    deinit {
        URLProtocolStub.requestHandler = nil
    }
    
    @Test
    func currentToken_isFetchedOnceAndCached() async throws {
        var fetchRequestCount = 0
        let json = """
        {
          "token": "token1",
          "expires_at": "2099-01-01T00:00:00Z"
        }
        """
        URLProtocolStub.requestHandler = { [weak self] _ in
            guard let self else {
                throw URLError(.cancelled)
            }
            
            fetchRequestCount += 1
            let data = Data(json.utf8)
            let response = HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let provider = TokenProvider(
            baseURL: baseURL,
            clientId: "id", clientSecret: "secret",
            urlSession: session,
            currentDate: { Date(timeIntervalSince1970: 0) }
        )
        
        let first = try await provider.provideToken()
        let second = try await provider.provideToken()
        
        #expect(first == "token1")
        #expect(second == "token1")
        #expect(fetchRequestCount == 1, "Token fetch should have been performed only once")
    }
    
    @Test
    func currentToken_afterExpiry_refreshes() async throws {
        var fetchRequestCount = 0
        let firstJSON = """
        {
          "token": "token1",
          "expires_at": "2025-06-01T12:00:00Z"
        }
        """
        let secondJSON = """
        {
          "token": "token2",
          "expires_at": "2099-01-01T00:00:00Z"
        }
        """
        URLProtocolStub.requestHandler = { [weak self] _ in
            guard let self else {
                throw URLError(.cancelled)
            }
            fetchRequestCount += 1
            let json = fetchRequestCount == 1 ? firstJSON : secondJSON
            let data = Data(json.utf8)
            let response = HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        
        var currentDate = ISO8601DateFormatter().date(from: "2025-06-01T11:59:59Z")!
        let provider = TokenProvider(
            baseURL: baseURL,
            clientId: "id", clientSecret: "secret",
            urlSession: session,
            currentDate: { currentDate }
        )
        
        let token1 = try await provider.provideToken()
        #expect(token1 == "token1")
        
        // current date passed expiry date
        currentDate = ISO8601DateFormatter().date(from: "2025-06-01T12:00:01Z")!
        let token2 = try await provider.provideToken()
        #expect(token2 == "token2")
        #expect(fetchRequestCount == 2, "Should have fetched twice: initial + refresh")
    }
    
    @Test
    func currentToken_concurrentCalls_onlyOneFetch() async throws {
        var fetchRequestCount = 0
        let json = """
        {
          "token": "same_token",
          "expires_at": "2099-01-01T00:00:00Z"
        }
        """
        URLProtocolStub.requestHandler = { [weak self] _ in
            guard let self else {
                throw URLError(.cancelled)
            }
            
            fetchRequestCount += 1
            try await Task.sleep(nanoseconds: 100_000_000)
            let data = Data(json.utf8)
            let response = HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
        
        let provider = TokenProvider(
            baseURL: baseURL,
            clientId: "id", clientSecret: "secret",
            urlSession: session,
            currentDate: { Date() }
        )
        
        async let token1Task = provider.provideToken()
        async let token2Task = provider.provideToken()
        let (token1, token2) = try await (token1Task, token2Task)
        
        #expect(token1 == "same_token")
        #expect(token2 == "same_token")
        #expect(fetchRequestCount == 1, "Concurrent calls should share the same refreshTask")
    }
    
    @Test
    func currentToken_throwsOnHttpError() async {
        URLProtocolStub.requestHandler = { [weak self] _ in
            guard let self else {
                throw URLError(.cancelled)
            }
            let response = HTTPURLResponse(
                url: baseURL,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        let provider = TokenProvider(
            baseURL: baseURL,
            clientId: "id", clientSecret: "secret",
            urlSession: session,
            currentDate: { Date() }
        )
        
        await #expect(throws: URLError(.userAuthenticationRequired), performing: {
            try await provider.provideToken()
        })
    }
    
    @Test
    func currentToken_throwsOnInvalidJSON() async {
        URLProtocolStub.requestHandler = { [weak self] _ in
            guard let self else {
                throw URLError(.cancelled)
            }
            let response = HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("invalid json".utf8))
        }
        let provider = TokenProvider(
            baseURL: baseURL,
            clientId: "id", clientSecret: "secret",
            urlSession: session,
            currentDate: { Date() }
        )
        
        await #expect(throws: DecodingError.self, performing: {
            try await provider.provideToken()
        })
    }
}
