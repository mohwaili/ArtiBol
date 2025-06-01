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
