//
//  UserResult.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 11.03.2025.
//

import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
