//
//  APIResponses+ArtworkDetail.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

extension APIResponse {
    
    struct ArtworkDetail {
        private init() { }
        static let successWithData = parseJSONContentInFile(withName: "ArtworkDetailResponse_SuccessWithData")
    }
}
