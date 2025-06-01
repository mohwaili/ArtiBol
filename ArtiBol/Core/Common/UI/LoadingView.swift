//
//  LoadingView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        VStack {
            ProgressView()
            Text(String(localized: "common_loading"))
                .fontDesign(.monospaced)
        }
    }
}
