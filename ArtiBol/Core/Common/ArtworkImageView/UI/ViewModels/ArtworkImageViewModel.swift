//
//  ArtworkImageViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

@MainActor
protocol ArtworkImageViewModel: ObservableObject {
    var viewState: ViewState<UIImage> { get }
    
    func loadImage() async
}

final class ArtworkImageViewModelImpl: ArtworkImageViewModel {
    
    @Published private(set) var viewState: ViewState<UIImage> = .loading
    
    private let imageLoader: ImageLoader
    
    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }
    
    func loadImage() async {
        viewState = .loading
        do {
            let data = try await imageLoader.execute()
            if let image = UIImage(data: data) {
                viewState = .loaded(image)
            } else {
                viewState = .error
            }
        } catch {
            viewState = .error
        }
    }
}
