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
        imageCache: URLCache = .imageCache,
        baseURL: URL
    ) -> ArtworkDetailView<ArtworkDetailViewModelImp<ArtworkImageViewModelImpl>> {
        let artworkDetailLoader = ArtworkDetailLoader(
            artworkId: artworkId,
            client: client,
            baseURL: baseURL
        )
        let viewModel = ArtworkDetailViewModelImp<ArtworkImageViewModelImpl>(
            artworkDetailLoader: artworkDetailLoader,
            imageViewModelFactory: { imageURL in
                ArtworkImageViewModelImpl(
                    imageLoader: ImageLoader(
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
