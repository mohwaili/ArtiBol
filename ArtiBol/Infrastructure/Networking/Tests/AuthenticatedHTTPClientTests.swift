//
//  AuthenticatedHTTPClientTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation
import Testing
@testable import ArtiBol

@Suite(.serialized)
class AuthenticatedHTTPClientTests {
    
    private let session: URLSession
    private let tokenProvider: FakeTokenProvider
    private let client: AuthenticatedHTTPClient
    private let baseURL = URL(string: "https://artibol.com/api")!

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        self.session = URLSession(configuration: config)

        self.tokenProvider = FakeTokenProvider(token: "test-token")
        self.client = AuthenticatedHTTPClient(session: session, tokenProvider: tokenProvider)
    }

    deinit {
        URLProtocolStub.requestHandler = nil
    }

    @Test
    func data_success_attachesTokenAndReturnsData() async throws {
        let expectedData = Data("hello".utf8)
        URLProtocolStub.requestHandler = { request in
            #expect(request.value(forHTTPHeaderField: "X-Xapp-Token") == "test-token")
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, expectedData)
        }

        let (data, response) = try await client.data(with: URLRequest(url: baseURL))
        
        #expect(data == expectedData)
        #expect(response.statusCode == 200)
        #expect(tokenProvider.provideCount == 1)
    }

    @Test
    func data_unauthorized_retriesAndSucceeds() async throws {
        var requestCount = 0
        let secondData = Data("world".utf8)

        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            if requestCount == 1 {
                let response401 = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response401, Data())
            } else {
                #expect(request.value(forHTTPHeaderField: "X-Xapp-Token") == "test-token")
                let response200 = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response200, secondData)
            }
        }

        let (data, response) = try await client.data(with: URLRequest(url: baseURL))
        
        #expect(data == secondData)
        #expect(response.statusCode == 200)
        #expect(requestCount == 2)
        #expect(tokenProvider.provideCount == 2)
    }

    @Test
    func data_unauthorized_retryFails_throwsUserAuthenticationRequiredError() async {
        var requestCount = 0
        URLProtocolStub.requestHandler = { request in
            requestCount += 1
            let status = requestCount == 1 ? 401 : 500
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        await #expect(throws: URLError(.userAuthenticationRequired), performing: {
            try await self.client.data(with: URLRequest(url: self.baseURL))
        })
        
        #expect(requestCount == 2)
        #expect(tokenProvider.provideCount == 2)
    }

    @Test
    func data_non200NonUnauthorized_throwsBadServerResponseError() async {
        URLProtocolStub.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        await #expect(throws: URLError(.badServerResponse), performing: {
            try await self.client.data(with: URLRequest(url: self.baseURL))
        })
        
        #expect(tokenProvider.provideCount == 1)
    }
    
    @Test
    func data_nonHTTPURLResponse_throwsBadServerResponseError() async {
        URLProtocolStub.requestHandler = { request in
            let response = URLResponse(
                url: request.url!,
                mimeType: "text/html",
                expectedContentLength: 1000,
                textEncodingName: nil
            )
            return (response, Data())
        }

        await #expect(throws: URLError(.badServerResponse), performing: {
            try await self.client.data(with: URLRequest(url: self.baseURL))
        })
        
        #expect(tokenProvider.provideCount == 1)
    }
}

private class FakeTokenProvider: TokenProviding, @unchecked Sendable {
    var provideCount = 0
    let tokenToProvide: String

    init(token: String) {
        self.tokenToProvide = token
    }

    func provideToken() async throws -> String {
        provideCount += 1
        return tokenToProvide
    }
}
