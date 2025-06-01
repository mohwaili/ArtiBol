//
//  ImageLoader.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import UIKit

enum ImageLoaderError: Error {
    case invalidURL
}

actor ImageLoader: Sendable {
    
    private let url: URL?
    private let client: HTTPClient
    private let cache: URLCache
    
    private var currentTask: Task<Data, Error>?
    
    init(url: URL?, client: HTTPClient, cache: URLCache) {
        self.url = url
        self.client = client
        self.cache = cache
    }
    
    func execute() async throws -> Data {
        guard let url else {
            throw ImageLoaderError.invalidURL
        }
        let request = URLRequest(url: url)
        if let cachedResponse = cache.cachedResponse(for: request) {
            return cachedResponse.data
        }
        
        if let task = currentTask, !task.isCancelled {
            return try await task.value
        }
        
        let task = Task<Data, Error> {
            let (data, response) = try await client.data(with: request)
            try Task.checkCancellation()
            cache.storeCachedResponse(
                CachedURLResponse(response: response, data: data),
                for: request
            )
            return data
        }
        
        currentTask = task
        
        do {
            let data = try await task.value
            currentTask = nil
            return data
        } catch {
            currentTask = nil
            throw error
        }
    }
}
