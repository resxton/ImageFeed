//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 08.03.2025.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
