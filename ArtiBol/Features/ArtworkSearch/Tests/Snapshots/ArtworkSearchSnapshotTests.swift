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
                viewState: nil
            ),
            artworkImageView: { _ in
                EmptyView()
            }
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_errorState() {
        let view = ArtworkSearchView(
            viewModel: SnapshotViewModel(
                viewState: .error
            ),
            artworkImageView: { _ in
                EmptyView()
            }
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
            ),
            artworkImageView: { _ in
                EmptyView()
            }
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
                query: "The cross"
            ),
            artworkImageView: { artworkSearchResult in
                ArtworkImageView(
                    viewModel: SnapshotImageViewModel(
                        viewState: artworkSearchResult.artworkId == "1" ? .loaded(.artImage2) : .loading
                    )
                )
            }
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
    
    @Published var destinations: Binding<[NavigationDestination]> = .constant([])
    @Published private(set) var viewState: ViewState<[ArtworkSearchResult]>?
    @Published var query: String = ""
    
    init(viewState: ViewState<[ArtworkSearchResult]>?,
         query: String = "") {
        self.viewState = viewState
        self.query = query
    }
    
    func search() async { }
    
    func navigateToArtworkDetail(id: String) { }
}
