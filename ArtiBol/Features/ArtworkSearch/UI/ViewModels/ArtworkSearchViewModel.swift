//
//  ArtworkSearchViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkSearchViewModel: ObservableObject {
    associatedtype ImageViewModel: ArtworkImageViewModel
    
    var viewState: ViewState<[ArtworkSearchResult]>? { get }
    var query: String { get set }
    
    func search() async
    func makeArtworkImageViewModel(for searchResult: ArtworkSearchResult) -> ImageViewModel
}

final class ArtworkSearchViewModelImpl<ImageViewModel: ArtworkImageViewModel>: ArtworkSearchViewModel {
    
    private(set) var destinations: Binding<[NavigationDestination]>
    
    @Published private(set) var viewState: ViewState<[ArtworkSearchResult]>? = nil
    @Published var query: String = ""
    private var lastSearchQuery: String = ""
    
    private let artworkFinderFactory: (String) -> ArtworkFinder
    private let imageViewModelFactory: (URL?) -> ImageViewModel
    
    init(
        destinations: Binding<[NavigationDestination]>,
        artworkFinderFactory: @escaping (String) -> ArtworkFinder,
        imageViewModelFactory: @escaping (URL?) -> ImageViewModel
    ) {
        self.destinations = destinations
        self.artworkFinderFactory = artworkFinderFactory
        self.imageViewModelFactory = imageViewModelFactory
    }
    
    func search() async {
        guard !query.isEmpty else {
            return
        }
        
        guard query != lastSearchQuery else { return }
        viewState = .loading
        
        do {
            let searchResults = try await artworkFinderFactory(query).execute()
            viewState = .loaded(searchResults)
            lastSearchQuery = query
        } catch {
            viewState = .error
        }
    }
    
    func makeArtworkImageViewModel(for searchResult: ArtworkSearchResult) -> ImageViewModel {
        imageViewModelFactory(searchResult.thumbnailUrl)
    }
}

// MARK: - ArtworkDetailNavigator -

extension ArtworkSearchViewModelImpl: ArtworkDetailNavigator { }
