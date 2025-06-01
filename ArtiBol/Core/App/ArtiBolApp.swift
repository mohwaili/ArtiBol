//
//  ArtiBolApp.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

@main
struct ArtiBolApp: App {
    
    @State private var catalogDestinations: [NavigationDestination] = []
    @State private var searchDestinations: [NavigationDestination] = []
    
    init() {
        AppStyling.apply()
    }
    
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if CommandLine.arguments.contains("isRunningTests") {
                Text("Running tests...")
            } else {
                content
            }
            #else
            content
            #endif
        }
    }
    
    var content: some View {
        TabView {
            AppNavigator(destinations: $catalogDestinations) {
                ArtworkCatalogComposer.compose(destinations: $catalogDestinations)
            }
            .rootView
            .tabItem {
                Label(String(localized: "tab_item_art"), systemImage: "person.crop.artframe")
            }
            
            AppNavigator(
                destinations: $searchDestinations,
                content: {
                    ArtworkSearchComposer.compose(destinations: $searchDestinations)
            })
            .rootView
            .tabItem {
                Label(String(localized: "tab_item_search"), systemImage: "magnifyingglass.circle")
            }
        }
    }
}
