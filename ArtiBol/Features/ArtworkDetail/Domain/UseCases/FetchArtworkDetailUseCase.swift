//
//  FetchArtworkDetailUseCase.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

protocol ArtworkDetailLoading: Sendable {
    func load(id: String) async throws -> ArtworkDetail
}

final class FetchArtworkDetailUseCase: Sendable {
    
    private let id: String
    private let loader: ArtworkDetailLoading
    
    init(id: String, loader: ArtworkDetailLoading) {
        self.id = id
        self.loader = loader
    }
    
    func execute() async throws -> ArtworkDetail {
        try await loader.load(id: id)
    }
}
