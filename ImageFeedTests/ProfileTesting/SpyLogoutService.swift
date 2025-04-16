//
//  SpyLogoutService.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 15.04.2025.
//

import ImageFeed

final class SpyLogoutService: ProfileLogoutServiceProtocol {
    var didLogout = false
    func logout() {
        didLogout = true
    }
}
