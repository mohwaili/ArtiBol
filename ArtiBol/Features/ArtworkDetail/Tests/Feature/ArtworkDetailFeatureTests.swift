//
//  ArtworkDetailFeatureTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation
import SwiftUI
import Testing
@testable import ArtiBol

@MainActor
class ArtworkDetailFeatureTests {
    
    private let baseURL = URL(string: "https://www.artibol.com/api")!
    private let client: HTTPClient
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        self.client = URLSession(configuration: configuration)
    }
    
    deinit {
        URLProtocolStub.requestHandler = nil
    }
    
    @Test
    func onAppear_failsToLoadData() async {
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/artworks/1")!: .error(URLError(.badServerResponse))
        ])
        let sut = makeSUT(
            artworkId: "1",
            client: client,
            baseURL: baseURL
        )
        
        await sut.onAppear()
        
        guard case .error = sut.viewState else {
            Issue.record("Expected view state to be .error")
            return
        }
    }
    
    @Test
    func onAppear_LoadsData() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let client = URLSession(configuration: configuration)
        
        let stubbedData = APIResponse.ArtworkDetail.successWithData
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/artworks/1")!: .data(data: stubbedData, statusCode: 200)
        ])
        let sut = makeSUT(
            artworkId: "1",
            client: client,
            baseURL: baseURL
        )
        
        #expect(sut.navigationBarTitle == "-")
        
        await sut.onAppear()
        
        guard case .loaded(let artworkDetail) = sut.viewState else {
            Issue.record("Expected view state to be .error")
            return
        }
        let expectedArtworkDetail = try JSONDecoder().decode(Artwork.self, from: stubbedData)
        #expect(artworkDetail == expectedArtworkDetail)
        #expect(sut.navigationBarTitle == artworkDetail.title)
    }
}

private extension ArtworkDetailFeatureTests {
    
    func makeSUT(
        artworkId: String,
        client: HTTPClient,
        imageCache: URLCache = URLCache(),
        baseURL: URL
    ) -> ArtworkDetailViewModelImp {
        ArtworkDetailComposer.compose(
            artworkId: artworkId,
            client: client,
            imageLoadClient: client,
            imageCache: imageCache,
            baseURL: baseURL
        ).extractViewModel(ArtworkDetailViewModelImp.self)
    }
}
