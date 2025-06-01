//
//  AppNavigator.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

@MainActor
final class AppNavigator<Content: View>: Navigator {
    
    var destinations: Binding<[NavigationDestination]>
    private let content: () -> Content
    
    init(
        destinations: Binding<[NavigationDestination]>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.destinations = destinations
        self.content = content
    }
    
    var rootView: some View {
        NavigationStack(path: destinations) {
            content()
                .navigationDestination(for: NavigationDestination.self) { [self] destination in
                    destination.compose(destinations: destinations)
                }
        }
        .tint(Color.content)
    }
}
