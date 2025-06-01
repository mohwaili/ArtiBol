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

final class ArtworkCatalogViewModelImpl: ArtworkCatalogViewModel {
    
    @Published private(set) var viewState: ViewState<(artworks: [Artwork], loadingMore: Bool)> = .loading
    
    private let loadArtworksUseCase: LoadArtworksUseCase
    private let loadImageUseCaseFactory: (URL?) -> LoadImageUseCase
    private(set) var destinations: Binding<[NavigationDestination]>
    
    init(
        loadArtworksUseCase: LoadArtworksUseCase,
        loadImageUseCaseFactory: @escaping (URL?) -> LoadImageUseCase,
        destinations: Binding<[NavigationDestination]>
    ) {
        self.loadArtworksUseCase = loadArtworksUseCase
        self.loadImageUseCaseFactory = loadImageUseCaseFactory
        self.destinations = destinations
    }
    
    func onAppear() async {
        if case .loaded = viewState { return }
        await loadData(isRefreshing: false)
    }
    
    func loadData(isRefreshing: Bool) async {
        if !isRefreshing { viewState = .loading }
        do {
            let artworks = try await loadArtworksUseCase.load()
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
            let newArtworks = try await loadArtworksUseCase.loadMore()
            viewState = .loaded((artworks: artworks + newArtworks, loadingMore: false))
        } catch {
            viewState = .loaded((artworks: artworks, loadingMore: false))
        }
    }
    
    func makeCardViewModel(for artwork: Artwork) -> some ArtworkCardViewModel {
        ArtworkCardViewModelImpl(
            artwork: artwork,
            artImageviewModel: ArtworkImageViewModelImpl(
                loadImageUseCase: loadImageUseCaseFactory(artwork.image.url)
            )
        )
    }
}

// MARK: - ArtworkCatalogNavigator -

extension ArtworkCatalogViewModelImpl: ArtworkDetailNavigator { }
