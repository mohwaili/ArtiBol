//
//  ArtworkSearchComposer.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

@MainActor
struct ArtworkSearchComposer {
    
    static func compose(
        destinations: Binding<[NavigationDestination]>,
        client: any HTTPClient = AuthenticatedHTTPClient(
            session: .shared,
            tokenProvider: TokenProvider.shared
        ),
        imageClient: HTTPClient = URLSession.shared,
        imageCache: URLCache = .imageCache,
        baseURL: URL = AppConfig.URLS.baseAPIURL
    ) -> some View {
        let viewModel = ArtworkSearchViewModelImpl(
            destinations: destinations,
            artworkFinderFactory: { query in
                ArtworkFinder(client: client, baseURL: baseURL, query: query)
            }
        )
        return ArtworkSearchView(
            viewModel: viewModel,
            artworkImageView: { artworkSearchResult in
                ArtworkImageView(
                    viewModel: ArtworkImageViewModelImpl(
                        imageLoader: ImageLoader(
                            url: artworkSearchResult.thumbnailUrl,
                            client: imageClient,
                            cache: imageCache
                        )
                    )
                )
            }
        )
    }
}
