//
//  ArtworkSearchFeatureTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation
import SwiftUI
import Testing
@testable import ArtiBol

@MainActor
class ArtworkSearchFeatureTests {
    
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
    func search_returnsOnEmptyQuery() async {
        let sut = makeSUT(client: client, baseURL: baseURL)
        sut.query = ""
        
        await sut.search()
        
        #expect(sut.viewState == nil)
    }
    
    @Test
    func search_loadsData() async {
        let stubbedData = APIResponse.ArtworkSearch.successWithData
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/search?q=Mona%20Lisa&type=artwork&size=10")!: .data(data: stubbedData, statusCode: 200)
        ])
        let sut = makeSUT(client: client, baseURL: baseURL)
        sut.query = "Mona Lisa"
        
        await sut.search()
        
        let expectedSearchResults = try! JSONDecoder().decode(ArtworkSearchResponse.self, from: stubbedData).results
        guard case .loaded(let searchResults) = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        #expect(searchResults == expectedSearchResults)
    }

    @Test
    func deleteQuery_resetsViewStateToNil() async {
        let stubbedData = APIResponse.ArtworkSearch.successWithData
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/search?q=Mona%20Lisa&type=artwork&size=10")!: .data(data: stubbedData, statusCode: 200)
        ])
        let sut = makeSUT(client: client, baseURL: baseURL)
        sut.query = "Mona Lisa"
        
        await sut.search()
        
        guard case .loaded = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        
        sut.query = ""
        await sut.search()

        #expect(sut.viewState == nil)
    }
    
    @Test
    func search_replacesCurrentSearchResultsWithNewResults() async {
        let monaLisaStubbedResults = APIResponse.ArtworkSearch.successWithData
        let vincentVanGoghStubbedResults = APIResponse.ArtworkSearch.successWithData2
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/search?q=Mona%20Lisa&type=artwork&size=10")!: .data(data: monaLisaStubbedResults, statusCode: 200),
            URL(string: "https://www.artibol.com/api/search?q=Vincent%20van%20Gogh&type=artwork&size=10")!: .data(data: vincentVanGoghStubbedResults, statusCode: 200)
        ])
        let sut = makeSUT(client: client, baseURL: baseURL)
        sut.query = "Mona Lisa"
        
        await sut.search()
        
        var expectedSearchResults = try! JSONDecoder().decode(ArtworkSearchResponse.self, from: monaLisaStubbedResults).results
        guard case .loaded(let firstLoadedResults) = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        #expect(firstLoadedResults == expectedSearchResults)
        
        sut.query = "Vincent van Gogh"
        
        await sut.search()
        
        expectedSearchResults = try! JSONDecoder().decode(ArtworkSearchResponse.self, from: vincentVanGoghStubbedResults).results
        guard case .loaded(let secondLoadedResults) = sut.viewState else {
            Issue.record("Expected view state to be .loaded")
            return
        }
        #expect(secondLoadedResults == expectedSearchResults)
        
        #expect(firstLoadedResults != secondLoadedResults)
    }
    
    @Test
    func search_fails() async {
        URLProtocolStub.stubRequests(stubs: [
            URL(string: "https://www.artibol.com/api/search?q=Mona%20Lisa&type=artwork&size=10")!: .error(URLError(.badServerResponse))
        ])
        let sut = makeSUT(client: client, baseURL: baseURL)
        sut.query = "Mona Lisa"
        
        await sut.search()
        
        guard case .error = sut.viewState else {
            Issue.record("Expected view state to be .error")
            return
        }
    }
    
    @Test
    func search_doesNothingWhenQueryIsNotChanged() async {
        let stubbedData = APIResponse.ArtworkSearch.successWithData
        var requestCount = 0
        URLProtocolStub.requestHandler = { request in
            guard let url = request.url else {
                fatalError("URL should not be nil")
            }
            if url.absoluteString == "https://www.artibol.com/api/search?q=Mona%20Lisa&type=artwork&size=10" {
                requestCount += 1
                return (
                    HTTPURLResponse(
                        url: url,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!,
                    stubbedData
                )
            }
            fatalError("Not implemented! \(url)")
        }
        let sut = makeSUT(client: client, baseURL: baseURL)
        sut.query = "Mona Lisa"
        
        await sut.search()
        await sut.search()
        
        #expect(requestCount == 1)
    }
}

private extension ArtworkSearchFeatureTests {
    
    func makeSUT(
        destinations: Binding<[NavigationDestination]> = .constant([]),
        client: HTTPClient,
        imageCache: URLCache = URLCache(),
        baseURL: URL
    ) -> ArtworkSearchViewModelImpl {
        ArtworkSearchComposer.compose(
            destinations: destinations,
            client: client,
            imageClient: client,
            imageCache: imageCache,
            baseURL: baseURL
        ).extractViewModel(ArtworkSearchViewModelImpl.self)
    }
}
