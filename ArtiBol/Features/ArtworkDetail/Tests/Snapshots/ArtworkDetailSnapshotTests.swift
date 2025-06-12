//
//  ArtworkDetailSnapshotTests.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import XCTest
import SwiftUI
@testable import ArtiBol

@MainActor
final class ArtworkDetailSnapshotTests: SnapshotTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        record = .missing
    }
    
    func test_errorState() {
        let view = ArtworkDetailView(
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
        let view = ArtworkDetailView(
            viewModel: SnapshotViewModel(
                viewState: .loading
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
        let view = ArtworkDetailView(
            viewModel: SnapshotViewModel(viewState: .loaded(
                makeArtworkDetail(
                    id: "1",
                    title: "The cross",
                    date: "200 AD - 400 AD",
                    dimensions: ArtworkDimensions(height: 473, width: 640, text: "473 x 640")
                    )
            )),
            artworkImageView: { _ in
                ArtworkImageView(
                    viewModel: SnapshotImageViewModel(viewState: .loaded(.artImage2))
                )
            }
        )
        
        let sut = UIHostingController(rootView: view)
        assertView(for: sut)
        assertView(for: sut, isDarkMode: true)
    }
}

// MARK: - Private -

private extension ArtworkDetailSnapshotTests {
    
    func makeArtworkDetail(
        id: String,
        title: String,
        date: String,
        dimensions: ArtworkDimensions
    ) -> ArtworkDetail {
        ArtworkDetail(
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

private class SnapshotViewModel: ArtworkDetailViewModel {
    @Published private(set) var viewState: ViewState<ArtworkDetail>
    
    init(viewState: ViewState<ArtworkDetail>) {
        self.viewState = viewState
    }
    
    let navigationBarTitle: String = ""
    
    func onAppear() async { }
    func loadData() async { }
}
