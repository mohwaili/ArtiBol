//
//  ArtworkSearchResult.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

struct ArtworkSearchResult {

    let title: String
    let description: String
    let thumbnailUrl: URL?
    let artworkId: String?
}

extension ArtworkSearchResult: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case links = "_links"
        case thumbnail
        case `self`
        case href
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        
        let linksContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .links)
        let thumbnailContainer = try linksContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnail)
        self.thumbnailUrl = try thumbnailContainer.decodeIfPresent(URL.self, forKey: .href)
        let selfContainer = try linksContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .`self`)
        if let artworkURLString = try selfContainer.decodeIfPresent(String.self, forKey: .href),
           let url = URL(string: artworkURLString) {
            self.artworkId = url.lastPathComponent
        } else {
            self.artworkId = nil
        }
    }
}

extension ArtworkSearchResult: Equatable {
    
    var id: String {
        artworkId ?? UUID().uuidString
    }
}
