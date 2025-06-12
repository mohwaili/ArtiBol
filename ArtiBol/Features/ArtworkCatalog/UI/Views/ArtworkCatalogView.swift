//
//  ArtworkCatalogView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

struct ArtworkCatalogView<
    ViewModel: ArtworkCatalogViewModel & ArtworkDetailNavigator,
    CardView: View
>: View {
    
    @ObservedObject private var viewModel: ViewModel
    private let cardView: (Artwork) -> CardView
    
    init(viewModel: ViewModel, cardView: @escaping (Artwork) -> CardView) {
        self.viewModel = viewModel
        self.cardView = cardView
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .loading:
                LoadingView()
            case .loaded(let (artworks, loadingMore)):
                makeLoadedState(
                    artworks: artworks,
                    loadingMore: loadingMore
                )
            case .error:
                ErrorRetryView(onRetry: {
                    await viewModel.loadData(isRefreshing: false)
                })
            }
        }
        .navigationTitle(String(localized: "screen_title_catalog"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
    }
}

private extension ArtworkCatalogView {
    
    @ViewBuilder
    func makeLoadedState(
        artworks: [Artwork],
        loadingMore: Bool
    ) -> some View {
        if artworks.isEmpty {
            ErrorRetryView(
                message: String(localized: "art_catalog_empty_message"),
                onRetry: {
                    await viewModel.loadData(isRefreshing: false)
                }
            )
        } else {
            makeListView(artworks: artworks, loadingMore: loadingMore)
        }
    }
    
    func makeListView(artworks: [Artwork], loadingMore: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(artworks.enumerated()), id: \.element.id) { index, artwork in
                    cardView(artwork)
                    .onAppear {
                        if index >= artworks.count - 2 {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                    .onTapGesture {
                        viewModel.navigateToArtworkDetail(id: artwork.id)
                    }
                }
                if loadingMore {
                    ProgressView()
                        .padding()
                }
            }
        }
        .refreshable {
            await viewModel.loadData(isRefreshing: true)
        }
    }
}

// MARK: - Previews -

private class PreviewArtworkImageViewModel: ArtworkImageViewModel {
 
    @Published private(set) var viewState: ViewState<UIImage>
    
    init(viewState: ViewState<UIImage>) {
        self.viewState = viewState
    }
    
    func loadImage() async { }
}

private class PreviewCardViewModel: ArtworkCardViewModel {
    
    let artwork: Artwork
    
    init(artwork: Artwork) {
        self.artwork = artwork
    }
    
    nonisolated var id: String {
        UUID().uuidString
    }
}

private class PreviewViewModel: ArtworkCatalogViewModel, ArtworkDetailNavigator {
   
    @Published private(set) var viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)>
    
    init(viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)>) {
        self.viewState = viewState
    }
    
    var destinations: Binding<[NavigationDestination]> = .constant([])
    
    func onAppear() async { }
    func loadData(isRefreshing: Bool) async { }
    func loadMore() async { }
}

private let previewArtWorks: [Artwork] = [
    .init(
        id: "1",
        title: "Virgin of the Rocks",
        category: "Unknown",
        medium: "Wood",
        date: "17th century",
        dimensions: ArtworkDimensions(height: 640, width: 392, text: "392 x 640"),
        image: ArtworkImage(url: nil)
    ),
    .init(
        id: "2",
        title: "Virgin of the Rocks",
        category: "Unknown",
        medium: "Wood",
        date: "17th century",
        dimensions: ArtworkDimensions(height: 473, width: 640, text: "392 x 640"),
        image: ArtworkImage(url: nil)
    )
]

#Preview("Loaded") {
    ArtworkCatalogView(
        viewModel: PreviewViewModel(
            viewState: .loaded((
                artworks: previewArtWorks,
                loadingMore: false
            ))
        ),
        cardView: { artwork in
            ArtworkCardView(
                viewModel: ArtworkCardViewModelImpl(artwork: artwork),
                artworkImageView: {
                    ArtworkImageView(
                        viewModel: PreviewArtworkImageViewModel(viewState: .loaded(.artImage1))
                    )
                }
            )
        }
    )
}

#Preview("Loaded (loading more)") {
    ArtworkCatalogView(
        viewModel: PreviewViewModel(
            viewState: .loaded((
                artworks: previewArtWorks,
                loadingMore: true
            ))
        ),
        cardView: { artwork in
            ArtworkCardView(
                viewModel: ArtworkCardViewModelImpl(artwork: artwork),
                artworkImageView: {
                    ArtworkImageView(
                        viewModel: PreviewArtworkImageViewModel(viewState: .loaded(.artImage1))
                    )
                }
            )
        }
    )
}

#Preview("Loading") {
    ArtworkCatalogView(
        viewModel: PreviewViewModel(viewState: .loading),
        cardView: { _ in
            EmptyView()
        }
    )
}

#Preview("Error") {
    ArtworkCatalogView(
        viewModel: PreviewViewModel(viewState: .error),
        cardView: { _ in
            EmptyView()
        }
    )
}
