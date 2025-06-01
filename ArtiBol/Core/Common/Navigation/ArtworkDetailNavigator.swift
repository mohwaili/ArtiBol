//
//  ArtworkDetailNavigator.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

@MainActor
protocol ArtworkDetailNavigator: Navigator {
    
    func navigateToArtworkDetail(id: String)
}

extension ArtworkDetailNavigator {
    
    func navigateToArtworkDetail(id: String) {
        navigate(to: .artworkDetail(id: id))
    }
}
