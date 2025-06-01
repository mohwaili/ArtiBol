//
//  ViewState.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import Foundation

enum ViewState<Data> {
    case loading
    case loaded(Data)
    case error
}
