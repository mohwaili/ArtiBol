//
//  ArtworkSearchSnapshotTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import XCTest
import SwiftUI
@testable import ArtiBol

@MainActor
final class ArtworkSearchSnapshotTests: SnapshotTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        record = .missing
    }
    
    func test_initialState() {
        let view = ArtworkSearchView(
            viewModel: SnapshotViewModel(
                viewState: nil,
                viewStateForSearchResult: { _ in .loading }
            )
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_errorState() {
        let view = ArtworkSearchView(
            viewModel: SnapshotViewModel(
                viewState: .error,
                viewStateForSearchResult: { _ in .loading }
            )
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_loadingState() {
        let view = ArtworkSearchView(
            viewModel: SnapshotViewModel(
                viewState: .loading,
                query: "The cross",
                viewStateForSearchResult: { _ in .loading }
            )
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_loadedState() {
        let view = ArtworkSearchView(
            viewModel: SnapshotViewModel(
                viewState: .loaded(
                    [
                        makeArtworkSearchResult(
                            artworkId: "1",
                            title: "The cross",
                            description: "A painting of a cross"
                        ),
                        makeArtworkSearchResult(
                            artworkId: "2",
                            title: "Mona Lisa wearing a cross",
                            description: "The most famous painting in the world"
                        ),
                    ]
                ),
                query: "The cross",
                viewStateForSearchResult: { searchResult in
                    if searchResult.artworkId == "1" {
                        return .loaded(.artImage2)
                    } else {
                        return .loading
                    }
                }
            )
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
}

// MARK: - Private -

private extension ArtworkSearchSnapshotTests {
    
    func makeArtworkSearchResult(
        artworkId: String,
        title: String,
        description: String
    ) -> ArtworkSearchResult {
        ArtworkSearchResult(
            title: title,
            description: description,
            thumbnailUrl: nil,
            artworkId: artworkId
        )
    }
}

private class SnapshotViewModel: ArtworkSearchViewModel & ArtworkDetailNavigator {
    
    typealias ImageViewModel = SnapshotImageViewModel
    
    @Published var destinations: Binding<[NavigationDestination]> = .constant([])
    @Published private(set) var viewState: ViewState<[ArtworkSearchResult]>?
    @Published var query: String = ""
    
    let viewStateForSearchResult: (ArtworkSearchResult) -> ViewState<UIImage>
    
    init(viewState: ViewState<[ArtworkSearchResult]>?,
         query: String = "",
         viewStateForSearchResult: @escaping (ArtworkSearchResult) -> ViewState<UIImage>) {
        self.viewState = viewState
        self.query = query
        self.viewStateForSearchResult = viewStateForSearchResult
    }
    
    func search() async { }
    
    func makeArtworkImageViewModel(for searchResult: ArtworkSearchResult) -> ImageViewModel {
        ImageViewModel(viewState: viewStateForSearchResult(searchResult))
    }
    
    func navigateToArtworkDetail(id: String) { }
}
