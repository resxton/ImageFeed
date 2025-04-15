//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 08.03.2025.
//

import Foundation

public struct ProfileResult: Codable {
    var username: String
    var firstName: String
    var lastName: String
    var bio: String?
    
    public init(username: String, firstName: String, lastName: String, bio: String? = nil) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
