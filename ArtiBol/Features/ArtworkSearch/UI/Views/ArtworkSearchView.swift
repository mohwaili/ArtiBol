//
//  ArtworkSearchView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

struct ArtworkSearchView<
    ViewModel: ArtworkSearchViewModel & ArtworkDetailNavigator,
    ArtworkImageView: View
>: View {
    
    @ObservedObject private var viewModel: ViewModel
    private let artworkImageView: (ArtworkSearchResult) -> ArtworkImageView
    
    init(viewModel: ViewModel, artworkImageView: @escaping (ArtworkSearchResult) -> ArtworkImageView) {
        self.viewModel = viewModel
        self.artworkImageView = artworkImageView
    }
    
    var body: some View {
        ZStack {
            if let viewState = viewModel.viewState {
                switch viewState {
                case .loading:
                    LoadingView()
                case .loaded(let searchResults):
                    makeSearchResultsView(searchResults: searchResults)
                case .error:
                    ErrorRetryView {
                        await viewModel.search()
                    }
                }
            } else {
                initialView
            }
        }
        .navigationTitle(String(localized: "screen_title_search"))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.query)
        .task(id: viewModel.query) {
            do {
                try await Task.sleep(for: .milliseconds(600))
                await viewModel.search()
            } catch { }
        }
    }
}

// MARK: - Private -

private extension ArtworkSearchView {
    
    var initialView: some View {
        makeMessageView(
            systemImageName: "magnifyingglass.circle.fill",
            message: String(localized: "search_initial_state_message")
        )
    }
    
    var emptyView: some View {
        
        makeMessageView(
            systemImageName: "exclamationmark.magnifyingglass",
            message: String(format: String(localized: "search_no_results_state_message"), viewModel.query)
        )
    }
    
    func makeMessageView(systemImageName: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 60, height: 60)
            Text(message)
                .multilineTextAlignment(.center)
                .font(.body)
                .fontDesign(.monospaced)
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func makeSearchResultsView(searchResults: [ArtworkSearchResult]) -> some View {
        if searchResults.isEmpty {
            emptyView
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(searchResults, id: \.id) { searchResult in
                        makeSearchResultRowView(searchResult: searchResult)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    func makeSearchResultRowView(searchResult: ArtworkSearchResult) -> some View {
        HStack(alignment: .top) {
            artworkImageView(searchResult)
                .frame(width: 80, height: 80)
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(searchResult.title)
                    .font(.callout)
                    .fontDesign(.monospaced)
                Text(searchResult.description)
                    .font(.footnote)
                    .fontDesign(.monospaced)
            }
            .padding(.leading, 8)
            Spacer()
        }
        .onTapGesture {
            if let artworkId = searchResult.artworkId {
                viewModel.navigateToArtworkDetail(id: artworkId)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview -

private class PreviewImageViewModel: ArtworkImageViewModel {
    
    @Published private(set) var viewState: ViewState<UIImage>
    
    init(viewState: ViewState<UIImage>) {
        self.viewState = viewState
    }
    
    func loadImage() async { }
}

private class PreviewViewModel: ArtworkSearchViewModel, ArtworkDetailNavigator {
    
    var destinations: Binding<[NavigationDestination]> = .constant([])

    @Published private(set) var viewState: ViewState<[ArtworkSearchResult]>?
    @Published var query: String = "Vincent van Gogh"
    
    init(viewState: ViewState<[ArtworkSearchResult]>?) {
        self.viewState = viewState
    }
    
    func search() async { }
}

#Preview("Initial") {
    ArtworkSearchView(
        viewModel: PreviewViewModel(viewState: nil),
        artworkImageView: { _ in
            EmptyView()
        }
    )
}

#Preview("No Search Results") {
    ArtworkSearchView(
        viewModel: PreviewViewModel(viewState: .loaded([])),
        artworkImageView: { _ in
            EmptyView()
        }
    )
}

#Preview("Search Results") {
    ArtworkSearchView(
        viewModel: PreviewViewModel(
            viewState: .loaded([
                ArtworkSearchResult(title: "Vincent van Gogh Portrait 1", description: "A self portrait by Vincent van Gogh", thumbnailUrl: nil, artworkId: nil),
                ArtworkSearchResult(title: "van Gogh Portrait 2", description: "Another portrait by Vincent van Gogh", thumbnailUrl: nil, artworkId: nil)
            ])
        ),
        artworkImageView: { _ in
            ArtworkImageView(viewModel: PreviewImageViewModel(viewState: .loaded(.artImage1)))
        }
    )
}

#Preview("Loading") {
    ArtworkSearchView(
        viewModel: PreviewViewModel(viewState: .loading),
        artworkImageView: { _ in
            EmptyView()
        }
    )
}

#Preview("Error") {
    ArtworkSearchView(
        viewModel: PreviewViewModel(viewState: .error),
        artworkImageView: { _ in
            EmptyView()
        }
    )
}
