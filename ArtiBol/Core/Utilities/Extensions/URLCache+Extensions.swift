//
//  URLCache+Extensions.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 01/06/2025.
//

import Foundation

extension URLCache {
    
    static let imageCache = URLCache(
        memoryCapacity: 20 * 1024 * 1024, // 20 MB
        diskCapacity: 100 * 1024 * 1024,  // 100 MB
        diskPath: "image-cache"
    )
}
