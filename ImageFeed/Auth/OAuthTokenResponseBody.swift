//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 18.02.2025.
//

struct OAuthTokenResponseBody: Decodable {
    var accessToken: String
    var tokenType: String
    var refreshToken: String
    var scope: String
    var createdAt: Int
    var userID: Int
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case userID = "user_id"
        case username
    }
}
