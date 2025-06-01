//
//  ArtworkSearchResponse.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation

struct ArtworkSearchResponse {
    
    let results: [ArtworkSearchResult]
}

extension ArtworkSearchResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case results
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let embeddedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .embedded)
        self.results = try embeddedContainer.decode([ArtworkSearchResult].self, forKey: .results)
    }
}
