//
//  Profile.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 08.03.2025.
//

import Foundation

struct Profile {
    var username: String
    var name: String
    var loginName: String
    var bio: String?
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username ?? ""
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.username ?? "")"
        self.bio = profileResult.bio
    }
}
