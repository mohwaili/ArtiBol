//
//  ArtworkCardViewModelTests.swift
//  ArtiBol
//
//  Created by Mohammed Alwaili on 12/06/2025.
//

import Testing
@testable import ArtiBol

@MainActor
struct ArtworkCardViewModelTests {
    
    @Test
    func id_isSetCorrectly() {
        let sut = ArtworkCardViewModelImpl(
            artwork: Artwork(
                id: "1",
                title: "Artwork Title",
                category: "Art",
                medium: "Oil on canvas",
                date: "1920",
                dimensions: ArtworkDimensions(height: 100, width: 100, text: "100 x 100 cm"),
                image: ArtworkImage(url: nil)
            )
        )
        
        #expect(sut.id == "1")
    }
}
