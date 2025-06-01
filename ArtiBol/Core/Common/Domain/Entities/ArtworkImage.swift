//
//  ArtworkImage.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

struct ArtworkImage {
    let url: URL?
}

extension ArtworkImage: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case image
        case href
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .image)
        if let href = try imageContainer.decodeIfPresent(String.self, forKey: .href),
           let imageURL = URL(string: href.replacingOccurrences(of: "{image_version}", with: "large")) {
            self.url = imageURL
        } else {
            self.url = nil
        }
    }
}

extension ArtworkImage: Equatable { }
