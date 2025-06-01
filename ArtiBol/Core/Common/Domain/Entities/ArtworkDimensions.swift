//
//  ArtworkDimensions.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

struct ArtworkDimensions {
    let height: Double
    let width: Double
    let text: String
}

extension ArtworkDimensions: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case centimetre = "cm"
        case height
        case width
        case text
    }
    
    init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let cmContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .centimetre)
        
        let h = try cmContainer.decodeIfPresent(Double.self, forKey: .height)
        let w = try cmContainer.decodeIfPresent(Double.self, forKey: .width)
        self.text = try cmContainer.decodeIfPresent(String.self, forKey: .text) ?? "Unknown"
    
        if let heightVal = h {
            self.height = heightVal
            self.width  = w ?? heightVal
        } else if let widthVal = w {
            self.width  = widthVal
            self.height = widthVal
        } else {
            self.width  = 100
            self.height = 100
        }
    }
}

extension ArtworkDimensions: Equatable { }
