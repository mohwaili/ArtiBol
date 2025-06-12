//
//  Artwork.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

struct Artwork {
    
    let id: String
    let title: String
    let category: String
    let medium: String
    let date: String
    let dimensions: ArtworkDimensions
    let image: ArtworkImage
}

extension Artwork: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case medium
        case date
        case dimensions
        case image = "_links"
    }
}

extension Artwork: Equatable { }
