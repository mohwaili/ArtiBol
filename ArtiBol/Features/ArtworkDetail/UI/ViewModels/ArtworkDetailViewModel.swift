//
//  ArtworkDetailViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkDetailViewModel: ObservableObject {
    associatedtype ImageViewModel: ArtworkImageViewModel
    
    var viewState: ViewState<(ArtworkDetail, ImageViewModel)> { get }
    var navigationBarTitle: String { get }
    
    func onAppear() async
    func loadData() async
}

final class ArtworkDetailViewModelImp<ImageViewModel: ArtworkImageViewModel>: ArtworkDetailViewModel {
    
    @Published private(set) var viewState: ViewState<(ArtworkDetail, ImageViewModel)> = .loading
    
    var navigationBarTitle: String {
        if case .loaded(let (artworkDetail, _)) = viewState {
            return artworkDetail.title
        }
        return "-"
    }
    
    private let artworkDetailLoader: ArtworkDetailLoading
    private let imageViewModelFactory: (URL?) -> ImageViewModel
    
    init(
        artworkDetailLoader: ArtworkDetailLoading,
        imageViewModelFactory: @escaping (URL?) -> ImageViewModel
    ) {
        self.artworkDetailLoader = artworkDetailLoader
        self.imageViewModelFactory = imageViewModelFactory
    }
    
    func onAppear() async {
        if case .loaded = viewState { return }
        
        await loadData()
    }
    
    func loadData() async {
        viewState = .loading
        do {
            let artworkDetail = try await artworkDetailLoader.load()
            let imageViewModel = imageViewModelFactory(artworkDetail.image.url)
            viewState = .loaded((artworkDetail, imageViewModel))
        } catch {
            viewState = .error
        }
    }
}
