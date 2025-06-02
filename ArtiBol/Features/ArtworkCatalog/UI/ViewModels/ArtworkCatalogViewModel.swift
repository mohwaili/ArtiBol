//
//  ArtworkCatalogViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkCatalogViewModel: ObservableObject {
    associatedtype CardViewModel: ArtworkCardViewModel
    
    var viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)> { get }
    
    func onAppear() async
    func loadData(isRefreshing: Bool) async
    func loadMore() async
    
    func makeCardViewModel(for artwork: Artwork) -> CardViewModel
}

final class ArtworkCatalogViewModelImpl<ImageViewModel: ArtworkImageViewModel>: ArtworkCatalogViewModel {
    
    @Published private(set) var viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)> = .loading
    
    private let artworksLoader: ArtworksLoading
    private let imageViewModelFactory: (URL?) -> ImageViewModel
    private(set) var destinations: Binding<[NavigationDestination]>
    
    init(
        artworksLoader: ArtworksLoading,
        imageViewModelFactory: @escaping (URL?) -> ImageViewModel,
        destinations: Binding<[NavigationDestination]>
    ) {
        self.artworksLoader = artworksLoader
        self.imageViewModelFactory = imageViewModelFactory
        self.destinations = destinations
    }
    
    func onAppear() async {
        if case .loaded = viewState { return }
        await loadData(isRefreshing: false)
    }
    
    func loadData(isRefreshing: Bool) async {
        if !isRefreshing { viewState = .loading }
        do {
            let artworks = try await artworksLoader.load()
            viewState = .loaded((artworks: artworks, loadingMore: false))
        } catch {
            viewState = .error
        }
    }
    
    func loadMore() async {
        guard case .loaded(let (artworks, loadingMore)) = viewState, !loadingMore else {
            return
        }
        viewState = .loaded((artworks: artworks, loadingMore: true))
        do {
            let newArtworks = try await artworksLoader.loadMore()
            viewState = .loaded((artworks: artworks + newArtworks, loadingMore: false))
        } catch {
            viewState = .loaded((artworks: artworks, loadingMore: false))
        }
    }
    
    func makeCardViewModel(for artwork: Artwork) -> some ArtworkCardViewModel {
        ArtworkCardViewModelImpl(
            artwork: artwork,
            artImageviewModel: imageViewModelFactory(artwork.image.url)
        )
    }
}

// MARK: - ArtworkCatalogNavigator -

extension ArtworkCatalogViewModelImpl: ArtworkDetailNavigator { }
