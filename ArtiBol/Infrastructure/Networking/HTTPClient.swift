//
//  HTTPClient.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

protocol HTTPClient: Sendable {
    
    func data(with request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
