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
    
    private let searchForArtworkUseCaseFactory: (String) -> SearchForArtworksUseCase
    private let loadImageUseCaseFactory: (URL?) -> LoadImageUseCase
    
    init(
        destinations: Binding<[NavigationDestination]>,
        searchForArtworkUseCaseFactory: @escaping (String) -> SearchForArtworksUseCase,
        loadImageUseCaseFactory: @escaping (URL?) -> LoadImageUseCase
    ) {
        self.destinations = destinations
        self.searchForArtworkUseCaseFactory = searchForArtworkUseCaseFactory
        self.loadImageUseCaseFactory = loadImageUseCaseFactory
    }
    
    func search() async {
        guard !query.isEmpty else {
            return
        }
        
        guard query != lastSearchQuery else { return }
        viewState = .loading
        
        do {
            let searchResults = try await searchForArtworkUseCaseFactory(query).execute()
            viewState = .loaded(searchResults)
            lastSearchQuery = query
        } catch {
            viewState = .error
        }
    }
    
    func makeArtworkImageViewModel(for searchResult: ArtworkSearchResult) -> some ArtworkImageViewModel {
        ArtworkImageViewModelImpl(loadImageUseCase: loadImageUseCaseFactory(searchResult.thumbnailUrl))
    }
}

// MARK: - ArtworkDetailNavigator -

extension ArtworkSearchViewModelImpl: ArtworkDetailNavigator { }
