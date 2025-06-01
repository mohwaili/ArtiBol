//
//  AppConfig.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 29/05/2025.
//

import Foundation

enum AppConfig {
    
    private static var config: [String: Any] {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("⚠️ Info.plist not found!")
        }
        guard let config = dict["BUILD_CONFIG"] as? [String: Any] else {
            fatalError("⚠️ BUILD_CONFIG in Info.plist not found!")
        }
        return config
    }
}

// MARK: - URLs -

extension AppConfig {
    
    enum URLS {
        
        static var baseAPIURL: URL {
            guard let urlString = config["BASE_API_URL"] as? String,
                  let url = URL(string: "https://\(urlString)") else {
                fatalError("⚠️ BASE_API_URL missing or malformed in Info.plist")
            }
            return url
        }
    }
}

// MARK: - Keys -

extension AppConfig {
    
    enum Keys {
        
        static var clientID: String {
            guard let id = config["CLIENT_ID"] as? String else {
                fatalError("⚠️ CLIENT_ID missing in Info.plist")
            }
            return id
        }
        
        static var clientSecret: String {
            guard let secret = config["CLIENT_SECRET"] as? String else {
                fatalError("⚠️ CLIENT_SECRET missing in Info.plist")
            }
            return secret
        }
    }
}
