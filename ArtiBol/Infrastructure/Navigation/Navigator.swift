//
//  Navigator.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import SwiftUI

@MainActor
protocol Navigator {
    var destinations: Binding<[NavigationDestination]> { get }

    func navigate(to destination: NavigationDestination)
}

extension Navigator {
    
    func navigate(to destination: NavigationDestination){
        destinations.wrappedValue.append(destination)
    }
}
