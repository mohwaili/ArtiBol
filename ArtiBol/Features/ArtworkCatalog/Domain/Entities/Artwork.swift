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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.category = try container.decode(String.self, forKey: .category)
        self.medium = try container.decodeIfPresent(String.self, forKey: .medium) ?? "Unknown"
        self.date = try container.decode(String.self, forKey: .date)
        self.dimensions = try container.decode(ArtworkDimensions.self, forKey: .dimensions)
        self.image = try container.decode(ArtworkImage.self, forKey: .image)
    }
}

extension Artwork: Equatable { }
