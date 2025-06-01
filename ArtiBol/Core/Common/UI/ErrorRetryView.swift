//
//  ErrorRetryView.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import SwiftUI

struct ErrorRetryView: View {
    
    let message: String
    let onRetry: () async -> Void
    
    init(
        message: String = "Something went wrong...",
        onRetry: @escaping () async -> Void
    ) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack {
            Text(message)
                .multilineTextAlignment(.center)
                .fontDesign(.monospaced)
            Button {
                Task {
                    await onRetry()
                }
            } label: {
                Text(String(localized: "common_try_again"))
                    .fontDesign(.monospaced)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
    }
}
