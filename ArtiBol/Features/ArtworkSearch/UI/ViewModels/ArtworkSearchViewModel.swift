//
//  ArtworkSearchViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkSearchViewModel: ObservableObject {
    var viewState: ViewState<[ArtworkSearchResult]>? { get }
    var query: String { get set }
    
    func search() async
}

final class ArtworkSearchViewModelImpl: ArtworkSearchViewModel {
    
    private(set) var destinations: Binding<[NavigationDestination]>
    
    @Published private(set) var viewState: ViewState<[ArtworkSearchResult]>? = nil
    @Published var query: String = ""
    private var lastSearchQuery: String = ""
    
    private let artworkFinderFactory: (String) -> ArtworkFinder
    
    init(
        destinations: Binding<[NavigationDestination]>,
        artworkFinderFactory: @escaping (String) -> ArtworkFinder,
    ) {
        self.destinations = destinations
        self.artworkFinderFactory = artworkFinderFactory
    }
    
    func search() async {
        guard !query.isEmpty else {
            viewState = nil
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
}

// MARK: - ArtworkDetailNavigator -

extension ArtworkSearchViewModelImpl: ArtworkDetailNavigator { }
