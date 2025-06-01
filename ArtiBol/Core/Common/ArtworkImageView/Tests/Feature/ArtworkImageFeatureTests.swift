//
//  ArtworkImageFeatureTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation
import SwiftUI
import Testing
@testable import ArtiBol

@MainActor
class ArtworkImageFeatureTests {
    
    private let client: HTTPClient
    private let cache = URLCache()
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        self.client = URLSession(configuration: configuration)
    }
    
    deinit {
        URLProtocolStub.requestHandler = nil
        cache.removeAllCachedResponses()
    }
    
    @Test
    func loadImage_failsWhenURLIsNil() async {
        let sut = self.makeSUT(
            url: nil,
            client: client
        )
        
        await sut.loadImage()
        
        guard case .error = sut.viewState else {
            Issue.record("Expected view state to be .error")
            return
        }
    }
    
    @Test
    func loadImage_loadsAnImage() async {
        let url = URL(string: "https://www.cdn.artsy.com/image.png")!
        let imageData = UIImage(resource: .artImage2).pngData()!
        URLProtocolStub.stubRequests(stubs: [
            url: .data(data: imageData, statusCode: 200)
        ])
        let sut = self.makeSUT(
            url: url,
            client: client
        )
        
        await sut.loadImage()
        
        guard case .loaded(let image) = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        #expect(image.pngData()! == imageData)
    }
    
    @Test
    func loadImageCalledTwice_loadsTheImageOnce() async {
        let imageURL = URL(string: "https://www.cdn.artsy.com/image.png")!
        let imageData = UIImage(resource: .artImage2).pngData()!
        var requestCount = 0
        URLProtocolStub.requestHandler = { request in
            guard let url = request.url else {
                fatalError("Request must have a URL.")
            }
            if url == imageURL {
                if requestCount == 0 {
                    try await Task.sleep(for: .milliseconds(500))
                }
                requestCount += 1
                return (
                    HTTPURLResponse(
                        url: url,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!,
                    imageData
                )
            }
            fatalError("Unhandled URL: \(url)")
        }
        let sut = self.makeSUT(
            url: imageURL,
            client: client
        )
        
        async let image1: () = sut.loadImage()
        async let image2: () = sut.loadImage()

        _ = await image1
        _ = await image2
        
        guard case .loaded(let image) = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        #expect(image.pngData()! == imageData)
        #expect(requestCount == 1)
    }
    
    @Test
    func loadImage_loadsACachedImage() async {
        let imageURL = URL(string: "https://www.cdn.artsy.com/image.png")!
        let imageData = UIImage(resource: .artImage2).pngData()!
        var requestCount = 0
        URLProtocolStub.requestHandler = { request in
            guard let url = request.url else {
                fatalError("Request must have a URL.")
            }
            if url == imageURL {
                requestCount += 1
                return (
                    HTTPURLResponse(
                        url: url,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!,
                    imageData
                )
            }
            fatalError("Unhandled URL: \(url)")
        }
        let sut = self.makeSUT(
            url: imageURL,
            client: client
        )
        
        await sut.loadImage()
        await sut.loadImage()
        
        guard case .loaded(let image) = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        #expect(image.pngData()! == imageData)
        #expect(requestCount == 1)
    }
    
    @Test
    func loadImage_failsOnCorruptedData() async {
        let url = URL(string: "https://www.cdn.artsy.com/image2.png")!
        let imageData = "corrupted_image_data".data(using: .utf8)!
        URLProtocolStub.stubRequests(stubs: [
            url: .data(data: imageData, statusCode: 200)
        ])
        let sut = self.makeSUT(
            url: url,
            client: client
        )
        
        await sut.loadImage()
        
        guard case .error = sut.viewState else {
            Issue.record("Expected view state to be .error")
            return
        }
    }
    
    @Test
    func loadImage_failsOnErrorStatusCode() async {
        let url = URL(string: "https://www.cdn.artsy.com/image2.png")!
        let imageData = "corrupted_image_data".data(using: .utf8)!
        URLProtocolStub.stubRequests(stubs: [
            url: .data(data: imageData, statusCode: 404)
        ])
        let sut = self.makeSUT(
            url: url,
            client: client
        )
        
        await sut.loadImage()
        
        guard case .error = sut.viewState else {
            Issue.record("Expected view state to be .error")
            return
        }
    }
}

private extension ArtworkImageFeatureTests {
    
    func makeSUT(
        url: URL?,
        client: HTTPClient
    ) -> ArtworkImageViewModelImpl {
        ArtworkImageViewModelImpl(
            loadImageUseCase: LoadImageUseCase(
                url: url,
                client: client,
                cache: cache
            )
        )
    }
}
