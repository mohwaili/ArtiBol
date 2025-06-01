//
//  ArtworkImageView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

struct ArtworkImageView<ViewModel: ArtworkImageViewModel>: View {
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            view(for: viewModel.viewState)
        }
        .onAppear {
            Task {
                await viewModel.loadImage()
            }
        }
    }
}

private extension ArtworkImageView {
    
    @ViewBuilder
    func view(for state: ViewState<UIImage>) -> some View {
        switch state {
        case .loading:
            placeholderView
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            
        case .loaded(let uIImage):
            Image(uiImage: uIImage)
                .resizable()
        case .error:
            placeholderView
        }
    }
    
    var placeholderView: some View {
        Color.gray.opacity(0.1)
    }
}
