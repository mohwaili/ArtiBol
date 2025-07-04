//
//  ArtworkDetailViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkDetailViewModel: ObservableObject, Sendable {
    var viewState: ViewState<Artwork> { get }
    var navigationBarTitle: String { get }
    
    func onAppear() async
    func loadData() async
}

final class ArtworkDetailViewModelImp: ArtworkDetailViewModel {
    
    @Published private(set) var viewState: ViewState<Artwork> = .loading
    
    var navigationBarTitle: String {
        if case .loaded(let artwork) = viewState {
            return artwork.title
        }
        return "-"
    }
    
    private let artworkDetailLoader: ArtworkDetailLoading
    
    init(artworkDetailLoader: ArtworkDetailLoading) {
        self.artworkDetailLoader = artworkDetailLoader
    }
    
    func onAppear() async {
        if case .loaded = viewState { return }
        
        await loadData()
    }
    
    func loadData() async {
        viewState = .loading
        do {
            let artworkDetail = try await artworkDetailLoader.load()
            viewState = .loaded(artworkDetail)
        } catch {
            viewState = .error
        }
    }
}
