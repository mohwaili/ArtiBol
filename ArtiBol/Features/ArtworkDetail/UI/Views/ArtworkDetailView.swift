//
//  ArtworkDetailView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

struct ArtworkDetailView<ViewModel: ArtworkDetailViewModel, ArtworkImageView: View>: View {
    
    @ObservedObject private var viewModel: ViewModel
    private let artworkImageView: (ArtworkDetail) -> ArtworkImageView
    
    init(viewModel: ViewModel, artworkImageView: @escaping (ArtworkDetail) -> ArtworkImageView) {
        self.viewModel = viewModel
        self.artworkImageView = artworkImageView
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .loading:
                LoadingView()
            case .loaded(let artworkDetail):
                makeLoadedState(artworkDetail: artworkDetail)
            case .error:
                ErrorRetryView(onRetry: {
                    await viewModel.loadData()
                })
            }
        }
        .navigationTitle(viewModel.navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
    }
}

private extension ArtworkDetailView {
    
    func makeLoadedState(artworkDetail: ArtworkDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                artworkImageView(artworkDetail)
                    .aspectRatio(artworkDetail.dimensions.width / artworkDetail.dimensions.height, contentMode: .fit)
                
                makeInfoView(artworkDetail: artworkDetail)
            }
            .padding(.bottom, 16)
        }
    }
    
    func makeInfoView(artworkDetail: ArtworkDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(artworkDetail.title)
                .font(.title)
                .fontDesign(.monospaced)
            
            VStack(alignment: .leading, spacing: 4) {
                makeInfoRow(key: "Date", value: artworkDetail.date)
                makeInfoRow(key: "Dimensions", value: artworkDetail.dimensions.text)
                makeInfoRow(key: "Category", value: artworkDetail.category)
                makeInfoRow(key: "Medium", value: artworkDetail.medium)
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
    }
    
    func makeInfoRow(key: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(verbatim: "\(key):")
                .font(.caption)
                .fontDesign(.monospaced)
            Text(value)
                .font(.caption)
                .fontDesign(.monospaced)
        }
    }
}

// MARK: - Previews -

private class PreviewArtImageViewModel: ArtworkImageViewModel {
    
    @Published private(set) var viewState: ViewState<UIImage>
    
    init(viewState: ViewState<UIImage>) {
        self.viewState = viewState
    }
    
    func loadImage() async { }
}

private class PreviewViewModel: ArtworkDetailViewModel {
    
    @Published private(set) var viewState: ViewState<ArtworkDetail>
    let navigationBarTitle: String = "-"
    
    init(viewState: ViewState<ArtworkDetail>) {
        self.viewState = viewState
    }
    
    func onAppear() async { }
    func loadData() async { }
}

private let artworkDetail = ArtworkDetail(
    id: "1",
    title: "Virgin of the Rocks",
    category: "Painting",
    medium: "Wood, transferred to canvas in 1806 by Hacquin",
    date: "17th century",
    dimensions: ArtworkDimensions(height: 640, width: 392, text: "392 x 640"),
    image: ArtworkImage(url: nil)
)

#Preview("Loaded") {
    ArtworkDetailView(
        viewModel: PreviewViewModel(
            viewState: .loaded(artworkDetail)
        ),
        artworkImageView: { _ in
            ArtworkImageView(
                viewModel: PreviewArtImageViewModel(
                    viewState: .loaded(
                        UIImage(resource: .artImage1)
                    )
                )
            )
        }
    )
}

#Preview("Loading") {
    ArtworkDetailView(
        viewModel: PreviewViewModel(viewState: .loading),
        artworkImageView: { _ in
            EmptyView()
        }
    )
}

#Preview("Error") {
    ArtworkDetailView(
        viewModel: PreviewViewModel(viewState: .error),
        artworkImageView: { _ in
            EmptyView()
        }
    )
}

