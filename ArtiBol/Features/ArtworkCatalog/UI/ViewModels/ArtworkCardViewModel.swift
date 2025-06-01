//
//  ArtworkCardViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import UIKit

@MainActor
protocol ArtworkCardViewModel: ObservableObject, Identifiable {
    associatedtype ImageViewModel: ArtworkImageViewModel
    
    var id: String { get }
    var artwork: Artwork { get }
    var artImageViewModel: ImageViewModel { get }
}

final class ArtworkCardViewModelImpl<ImageViewModel: ArtworkImageViewModel>: ArtworkCardViewModel {
    
    @Published private(set) var imageViewState: ViewState<UIImage> = .loading
    
    nonisolated var id: String {
        artwork.id
    }
    
    let artwork: Artwork
    let artImageViewModel: ImageViewModel
    
    init(
        artwork: Artwork,
        artImageviewModel: ImageViewModel
    ) {
        self.artwork = artwork
        self.artImageViewModel = artImageviewModel
    }
}
