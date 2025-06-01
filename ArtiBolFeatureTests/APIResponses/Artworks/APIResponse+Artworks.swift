//
//  APIResponse+Artworks.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

extension APIResponse {
    
    struct Artworks {
        private init() { }
        static let successWithData = parseJSONContentInFile(withName: "ArtworksResponse_SuccessWithData")
    }
}
