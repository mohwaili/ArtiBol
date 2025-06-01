//
//  SnapshotImageViewModel.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import UIKit
@testable import ArtiBol

class SnapshotImageViewModel: ArtworkImageViewModel {
    
    @Published private(set) var viewState: ViewState<UIImage>
    
    init(viewState: ViewState<UIImage>) {
        self.viewState = viewState
    }
    
    func loadImage() async { }
}
