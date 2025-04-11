//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 18.02.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let key = "OAuth2Token"
    private let keychain = KeychainWrapper.standard
    
    static let shared = OAuth2TokenStorage()
    
    private init() {}
    
    var token: String? {
        get {
            keychain.string(forKey: key)
        }
        set {
            guard let newValue else {
                keychain.removeObject(forKey: key)
                return
            }
            keychain.set(newValue, forKey: key)
        }
    }
    
    public func clearToken() {
        token = nil
    }
}
