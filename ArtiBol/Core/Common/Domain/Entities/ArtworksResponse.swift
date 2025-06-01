//
//  ArtworksResponse.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation

struct ArtworksResponse {
    
    let nextURL: URL?
    let artworks: [Artwork]
}

extension ArtworksResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case next = "next"
        case href
        case embedded = "_embedded"
        case artworks
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let linksContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .links)
        let nextContainer = try linksContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .next)
        if let href = try nextContainer.decodeIfPresent(String.self, forKey: .href),
           let url = URL(string: href) {
            self.nextURL = url
        } else {
            self.nextURL = nil
        }
        let embeddedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .embedded)
        self.artworks = try embeddedContainer.decode([Artwork].self, forKey: .artworks)
    }
}
