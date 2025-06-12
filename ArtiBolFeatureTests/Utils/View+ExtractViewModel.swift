//
//  Untitled.swift
//  ArtiBol
//
//  Created by Mohammed Alwaili on 12/06/2025.
//

import SwiftUI

extension View {
    
    func extractViewModel<T: ObservableObject>(_ type: T.Type) -> T {
        let mirror = Mirror(reflecting: self)
        guard let first = mirror.children.first?.value,
              let observedWrapper = first
                as? ObservedObject<T> else {
            fatalError("❌ Failed to extract view model of type \(String(describing: type))")
        }
        return observedWrapper.wrappedValue
    }
}

