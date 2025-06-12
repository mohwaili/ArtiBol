//
//  ArtworkCardViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import UIKit

@MainActor
protocol ArtworkCardViewModel: ObservableObject, Identifiable {
    var id: String { get }
    var artwork: Artwork { get }
}

final class ArtworkCardViewModelImpl: ArtworkCardViewModel {
    
    nonisolated var id: String {
        artwork.id
    }
    
    let artwork: Artwork
    
    init(artwork: Artwork) {
        self.artwork = artwork
    }
}
