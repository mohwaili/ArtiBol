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
    ) -> ArtworkSearchView<ArtworkSearchViewModelImpl<ArtworkImageViewModelImpl>> {
        let viewModel = ArtworkSearchViewModelImpl<ArtworkImageViewModelImpl>(
            destinations: destinations,
            searchForArtworkUseCaseFactory: { query in
                SearchForArtworksUseCase(client: client, baseURL: baseURL, query: query)
            },
            loadImageUseCaseFactory: { url in
                LoadImageUseCase(url: url, client: imageClient, cache: imageCache)
            }
        )
        return ArtworkSearchView(viewModel: viewModel)
    }
}
