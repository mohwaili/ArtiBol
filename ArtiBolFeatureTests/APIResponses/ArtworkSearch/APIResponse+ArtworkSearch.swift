//
//  APIResponse+ArtworkSearch.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

extension APIResponse {
    
    struct ArtworkSearch {
        private init() { }
        static let successWithData = parseJSONContentInFile(withName: "ArtworkSearchResponse_SuccessWithData")
        static let successWithData2 = parseJSONContentInFile(withName: "ArtworkSearchResponse_SuccessWithData_2")
    }
}
