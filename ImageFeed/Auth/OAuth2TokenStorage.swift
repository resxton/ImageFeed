//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 18.02.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private let key = "OAuth2Token"
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            userDefaults.string(forKey: key)
        }
        set {
            userDefaults.setValue(newValue, forKey: key)
        }
    }
    
    public func clearToken() {
        token = nil
    }
}
