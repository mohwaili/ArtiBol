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
    ) -> some View {
        let artworkDetailLoader = ArtworkDetailLoader(
            artworkId: artworkId,
            client: client,
            baseURL: baseURL
        )
        let viewModel = ArtworkDetailViewModelImp(
            artworkDetailLoader: artworkDetailLoader
        )
        return ArtworkDetailView(viewModel: viewModel) { artwork in
            ArtworkImageView(
                viewModel: ArtworkImageViewModelImpl(
                    imageLoader: ImageLoader(
                        url: artwork.image.url,
                        client: imageLoadClient,
                        cache: imageCache
                    )
                )
            )
        }
    }
}
