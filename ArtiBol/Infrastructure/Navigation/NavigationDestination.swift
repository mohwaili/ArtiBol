//
//  NavigationDestination.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

enum NavigationDestination: Hashable {
    
    case artworkDetail(id: String)
}

extension NavigationDestination {
    
    @MainActor
    @ViewBuilder
    func compose(destinations: Binding<[NavigationDestination]>) -> some View {
        switch self {
        case .artworkDetail(let id):
            ArtworkDetailComposer.compose(
                artworkId: id,
                client: AuthenticatedHTTPClient(
                    session: .shared,
                    tokenProvider: TokenProvider.shared
                ),
                baseURL: AppConfig.URLS.baseAPIURL
            )
        }
    }
}
