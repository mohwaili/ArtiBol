//
//  URLProtocolStub.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation
import XCTest
@testable import ArtiBol

final class URLProtocolStub: URLProtocol {
    
    nonisolated(unsafe) static var requestHandler: ((URLRequest) async throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = URLProtocolStub.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        Task {
            do {
                let (response, data) = try await handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {}
}

extension URLProtocolStub: @unchecked Sendable { }

enum RequestStub {
    case error(Error)
    case data(data: Data, statusCode: Int)
}

extension URLProtocolStub {
    
    static func stubRequests(
        stubs: [URL: RequestStub],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        requestHandler = { request in
            guard let url = request.url else {
                fatalError("URL should not be nil", file: file, line: line)
            }
            if let requestStub = stubs[url] {
                switch requestStub {
                case .error(let error):
                    throw error
                case .data(let data, let statusCode):
                    return (
                        HTTPURLResponse(
                            url: url,
                            statusCode: statusCode,
                            httpVersion: nil,
                            headerFields: nil
                        )!,
                        data
                    )
                }
            }
            fatalError("Not implemented! \(url)", file: file, line: line)
        }
    }
}
