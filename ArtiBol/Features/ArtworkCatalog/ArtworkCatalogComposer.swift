//
//  ArtworkCatalogComposer.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation
import SwiftUI

@MainActor
struct ArtworkCatalogComposer {
    
    static func compose(
        destinations: Binding<[NavigationDestination]>,
        artworksClient: HTTPClient = AuthenticatedHTTPClient(
            session: .shared,
            tokenProvider: TokenProvider.shared
        ),
        imageLoadClient: HTTPClient = URLSession.shared,
        imageCache: URLCache = .imageCache,
        baseURL: URL = AppConfig.URLS.baseAPIURL
    ) -> some View {
        let remoteLoader = RemoteArtworksLoader(client: artworksClient, baseURL: baseURL)
        let cachedLoader = CachedArtworksLoader()
        let artworksLoader = CompositeArtworksLoader(
            remoteLoader: remoteLoader,
            cachedLoader: cachedLoader
        )
        let viewModel = ArtworkCatalogViewModelImpl(
            artworksLoader: artworksLoader,
            destinations: destinations
        )
        return ArtworkCatalogView(
            viewModel: viewModel,
            cardView: { artwork in
                ArtworkCardView(
                    viewModel: ArtworkCardViewModelImpl(artwork: artwork),
                    artworkImageView: {
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
                )
        })
    }
}
