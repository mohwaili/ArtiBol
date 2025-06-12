//
//  ArtworkCardView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

struct ArtworkCardView<ViewModel: ArtworkCardViewModel, ArtworkImageView: View>: View {
    
    @StateObject var viewModel: ViewModel
    private let artworkImageView: () -> ArtworkImageView
    
    init(viewModel: ViewModel, artworkImageView: @escaping () -> ArtworkImageView) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.artworkImageView = artworkImageView
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            artworkImageView()
                .aspectRatio(viewModel.artwork.dimensions.width / viewModel.artwork.dimensions.height, contentMode: .fit)
            
            infoView
        }
    }
}

private extension ArtworkCardView {
    
    var infoView: some View {
        VStack(alignment: .leading) {
            Text(viewModel.artwork.date)
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(viewModel.artwork.title)
                .font(.headline)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .padding(.top, -16)
        )
    }
}

// MARK: - Preview -

private class PreviewArtworkImageViewModel: ArtworkImageViewModel {
    
    @Published private(set) var viewState: ViewState<UIImage>
    
    init(viewState: ViewState<UIImage>) {
        self.viewState = viewState
    }
    
    func loadImage() async { }
}

private class PreviewViewModel: ArtworkCardViewModel {
    
    let artwork: Artwork = Artwork(
        id: "1",
        title: "Virgin of the Rocks",
        category: "Unknown",
        medium: "Wood",
        date: "17th century",
        dimensions: ArtworkDimensions(height: 640, width: 392, text: "392 x 640"),
        image: ArtworkImage(url: nil)
    )
    
    nonisolated var id: String {
        UUID().uuidString
    }
}

#Preview("Loaded") {
    ArtworkCardView(
        viewModel: PreviewViewModel()) {
            ArtworkImageView(
                viewModel: PreviewArtworkImageViewModel(viewState: .loaded(.artImage1))
            )
        }
}

#Preview("Loading") {
    ArtworkCardView(
        viewModel: PreviewViewModel()) {
            ArtworkImageView(
                viewModel: PreviewArtworkImageViewModel(viewState: .loading)
            )
        }
}

#Preview("Error") {
    ArtworkCardView(
        viewModel: PreviewViewModel()) {
            ArtworkImageView(
                viewModel: PreviewArtworkImageViewModel(viewState: .error)
            )
        }
}
