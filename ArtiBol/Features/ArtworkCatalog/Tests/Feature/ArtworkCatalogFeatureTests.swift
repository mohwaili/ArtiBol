//
//  ArtworkCatalogFeatureTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation
import SwiftUI
import Testing
@testable import ArtiBol

@MainActor
class ArtworkCatalogFeatureTests {
    
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
            URL(string: "https://www.artibol.com/api/artworks?size=15")!: .error(URLError(.badServerResponse))
        ])
        let sut = makeSUT(
            client: client,
            baseURL: baseURL
        )
        
        await sut.onAppear()
        
        guard case .error = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
    }
    
    @Test
    func onAppear_loadsArtworks() async throws {
        let stubbedData = APIResponse.Artworks.successWithData
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/artworks?size=15")!: .data(data: stubbedData, statusCode: 200)
        ])
        
        let sut = makeSUT(
            client: client,
            baseURL: baseURL
        )
        
        await sut.onAppear()
        
        let expectedArtworks: [Artwork] = try JSONDecoder().decode(ArtworksResponse.self, from: stubbedData).artworks
        guard case .loaded(let (loadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(expectedArtworks == loadedArtworks)
    }
    
    @Test
    func onAppearAndLoadData_loadsAndCachesArtworks() async throws {
        let stubbedData = APIResponse.Artworks.successWithData
        var requestCount = 0
        URLProtocolStub.requestHandler = { request in
            guard let url = request.url else {
                fatalError("URL should not be nil")
            }
            if url.absoluteString == "https://www.artibol.com/api/artworks?size=15" {
                requestCount += 1
                if requestCount == 1 {
                    return (
                        HTTPURLResponse(
                            url: url,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )!,
                        stubbedData
                    )
                } else {
                    throw URLError(.badServerResponse)
                }
                
            }
            fatalError("Not implemented!")
        }
        
        let sut = makeSUT(
            client: client,
            baseURL: baseURL
        )
        
        await sut.onAppear()
        
        let expectedArtworks: [Artwork] = try JSONDecoder().decode(ArtworksResponse.self, from: stubbedData).artworks
        guard case .loaded(let (preReloadLoadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(preReloadLoadedArtworks == expectedArtworks)
        
        await sut.loadData(isRefreshing: false)
        
        guard case .loaded(let (postReloadLoadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(postReloadLoadedArtworks == expectedArtworks)
    }
    
    @Test
    func loadMore_loadsArtworks() async throws {
        let stubbedData = APIResponse.Artworks.successWithData
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/artworks?size=15")!: .data(data: stubbedData, statusCode: 200),
            URL(string: "https://api.artsy.net/api/artworks?cursor=4d8b93394eb68a1b2c0010fa%3A4d8b93394eb68a1b2c0010fa&size=3")!: .data(data: stubbedData, statusCode: 200)
        ])
        
        let sut = makeSUT(
            client: client,
            baseURL: baseURL
        )
        
        await sut.loadData(isRefreshing: false)
        
        let expectedArtworks: [Artwork] = try JSONDecoder().decode(ArtworksResponse.self, from: stubbedData).artworks
        guard case .loaded(let (preLoadMoreLoadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(expectedArtworks == preLoadMoreLoadedArtworks)
        
        await sut.loadMore()
        
        guard case .loaded(let (postLoadMoreLoadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(expectedArtworks + expectedArtworks == postLoadMoreLoadedArtworks)
    }
    
    @Test
    func loadMore_failsToLoadMore() async throws {
        let stubbedData = APIResponse.Artworks.successWithData
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/artworks?size=15")!: .data(data: stubbedData, statusCode: 200),
            URL(string: "https://api.artsy.net/api/artworks?cursor=4d8b93394eb68a1b2c0010fa%3A4d8b93394eb68a1b2c0010fa&size=3")!: .error(URLError(.badServerResponse))
        ])
        
        let sut = makeSUT(
            client: client,
            baseURL: baseURL
        )
        
        await sut.loadData(isRefreshing: false)
        
        let expectedArtworks: [Artwork] = try JSONDecoder().decode(ArtworksResponse.self, from: stubbedData).artworks
        guard case .loaded(let (preLoadMoreLoadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(expectedArtworks == preLoadMoreLoadedArtworks)
        
        await sut.loadMore()
        
        guard case .loaded(let (postLoadMoreLoadedArtworks, _)) = sut.viewState else {
            Issue.record("Expected view state to be .error but was \(sut.viewState)")
            return
        }
        #expect(expectedArtworks == postLoadMoreLoadedArtworks)
    }
    
    @Test
    func makeCardViewModel_createsViewModelWithCorrectData() {
        let imageURL = URL(string: "https://cdn.artsy.com/mona-lisa.png")!
        let artwork: Artwork = .init(
            id: "123",
            title: "Mona Lisa",
            category: "Painting",
            medium: "Oil",
            date: "c. 1503–1506",
            dimensions: ArtworkDimensions(height: 200, width: 120, text: "200 x 120"),
            image: ArtworkImage(url: imageURL)
        )
        let sut = makeSUT(client: URLSession(configuration: .ephemeral), baseURL: baseURL)
        
        let cardViewModel = sut.makeCardViewModel(for: artwork)
        
        #expect(cardViewModel.id == artwork.id)
        #expect(cardViewModel.artwork == artwork)
    }
    
    @Test
    func navigateToDetail() {
        var destinations: [NavigationDestination] = []
        let destinationsBinding = Binding<[NavigationDestination]>(
            get: { destinations },
            set: { destinations = $0 }
        )
        let sut = makeSUT(
            destinations: destinationsBinding,
            client: URLSession(configuration: .ephemeral),
            baseURL: baseURL
        )
        
        #expect(destinations.isEmpty)
        
        sut.navigateToArtworkDetail(id: "1")
        
        #expect(destinations.contains(.artworkDetail(id: "1")))
    }
}

private extension ArtworkCatalogFeatureTests {
    
    func makeSUT(
        destinations: Binding<[NavigationDestination]> = .constant([]),
        client: HTTPClient,
        baseURL: URL
    ) -> ArtworkCatalogViewModelImpl<ArtworkImageViewModelImpl> {
        ArtworkCatalogComposer.compose(
            destinations: destinations,
            artworksClient: client,
            imageLoadClient: client,
            imageCache: URLCache(),
            baseURL: baseURL
        ).viewModel
    }
}
