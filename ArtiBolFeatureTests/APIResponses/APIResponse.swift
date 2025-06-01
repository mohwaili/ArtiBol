//
//  APIResponse.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation

class APIResponse {
    
    private init() { }
    
    static func parseJSONContentInFile(withName name: String) -> Data {
        let bundle = Bundle(for: APIResponse.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            fatalError("🔴 Unable to locate “\(name).json” in bundle.")
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("🔴 Failed to load contents of “\(name).json”: \(error)")
        }
    }
}
