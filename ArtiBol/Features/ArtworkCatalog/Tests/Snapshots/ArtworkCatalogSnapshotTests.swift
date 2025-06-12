//
//  ArtworkCatalogSnapshotTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import XCTest
import SwiftUI
@testable import ArtiBol

@MainActor
final class ArtworkCatalogSnapshotTests: SnapshotTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        record = .missing
    }
    
    func test_emptyState() {
        let view = ArtworkCatalogView(
            viewModel: SnapshotViewModel(
                viewState: .loaded((artworks: [], loadingMore: false))
            ),
            cardView: { _ in
                EmptyView()
            }
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_errorState() {
        let view = ArtworkCatalogView(
            viewModel: SnapshotViewModel(
                viewState: .error
            ),
            cardView: { _ in
                EmptyView()
            }
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_loadingState() {
        let view = ArtworkCatalogView(
            viewModel: SnapshotViewModel(
                viewState: .loading
            ),
            cardView: { _ in
                EmptyView()
            }
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
    
    func test_loadedState() {
        let artworks: [Artwork] = [
            makeArtwork(
                id: "1",
                title: "The cross",
                date: "200 AD - 400 AD",
                dimensions: ArtworkDimensions(height: 473, width: 640, text: "473 x 640")
            ),
            makeArtwork(
                id: "2",
                title: "Mona Lisa",
                date: "c. 1503–1506",
                dimensions: ArtworkDimensions(height: 392, width: 640, text: "392 x 640")
            )
        ]
        let view = ArtworkCatalogView(
            viewModel: SnapshotViewModel(
                viewState: .loaded((artworks: artworks, loadingMore: false))
            ),
            cardView: { artwork in
                ArtworkCardView(
                    viewModel: ArtworkCardViewModelImpl(artwork: artwork),
                    artworkImageView: {
                        ArtworkImageView(
                            viewModel: SnapshotImageViewModel(viewState: artwork.id == "1" ? .loaded(.artImage2) : .loading)
                        )
                    }
                )
            }
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
}

// MARK: - Private -

private extension ArtworkCatalogSnapshotTests {
    
    func makeArtwork(
        id: String,
        title: String,
        date: String,
        dimensions: ArtworkDimensions
    ) -> Artwork {
        Artwork(
            id: id,
            title: title,
            category: "any",
            medium: "any",
            date: date,
            dimensions: dimensions,
            image: ArtworkImage(url: nil)
        )
    }
}

private class SnapshotViewModel: ArtworkCatalogViewModel, ArtworkDetailNavigator {
    
    @Published var destinations: Binding<[NavigationDestination]> = .constant([])
    @Published private(set) var viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)>
    
    init(viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)>) {
        self.viewState = viewState
    }
    
    func onAppear() async { }
    func loadData(isRefreshing: Bool) async { }
    func loadMore() async { }
}
