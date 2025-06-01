//
//  ArtworkDetailComposer.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation
import SwiftUI

@MainActor
struct ArtworkDetailComposer {
    
    static func compose(
        artworkId: String,
        client: HTTPClient,
        imageLoadClient: HTTPClient = URLSession.shared,
        imageCache: URLCache = .shared,
        baseURL: URL
    ) -> ArtworkDetailView<ArtworkDetailViewModelImp<ArtworkImageViewModelImpl>> {
        let remoteArtworkDetailLoader = RemoteArtworkDetailLoader(client: client, baseURL: baseURL)
        let fetchArtworkDetailUseCase = FetchArtworkDetailUseCase(
            id: artworkId,
            loader: remoteArtworkDetailLoader
        )
        let viewModel = ArtworkDetailViewModelImp<ArtworkImageViewModelImpl>(
            fetchArtworkDetailUseCase: fetchArtworkDetailUseCase,
            imageViewModelFactory: { imageURL in
                ArtworkImageViewModelImpl(
                    loadImageUseCase: LoadImageUseCase(
                        url: imageURL,
                        client: imageLoadClient,
                        cache: imageCache
                    )
                )
            }
        )
        return ArtworkDetailView(viewModel: viewModel)
    }
}
