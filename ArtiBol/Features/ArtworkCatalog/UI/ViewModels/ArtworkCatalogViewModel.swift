//
//  ArtworkCatalogViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkCatalogViewModel: ObservableObject, Sendable {
    var viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)> { get }
    
    func onAppear() async
    func loadData(isRefreshing: Bool) async
    func loadMore() async
}

final class ArtworkCatalogViewModelImpl: ArtworkCatalogViewModel {
    
    @Published private(set) var viewState: ViewState<(
        artworks: [Artwork],
        loadingMore: Bool
    )> = .loading
    
    private let artworksLoader: ArtworksLoading
    private(set) var destinations: Binding<[NavigationDestination]>
    
    init(
        artworksLoader: ArtworksLoading,
        destinations: Binding<[NavigationDestination]>
    ) {
        self.artworksLoader = artworksLoader
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
}

// MARK: - ArtworkCatalogNavigator -

extension ArtworkCatalogViewModelImpl: ArtworkDetailNavigator { }
