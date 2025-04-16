//
//  Photo.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 20.03.2025.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}

public struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case urls
        case isLiked = "liked_by_user"
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()
    
    var date: Date? {
        return PhotoResult.dateFormatter.date(from: createdAt)
    }
}

public struct UrlsResult: Codable {
    let thumb: String
    let large: String
    let full: String

    enum CodingKeys: String, CodingKey {
        case thumb
        case large = "regular"
        case full
    }
}

public struct LikePhotoResponse: Codable {
    let photo: PhotoResult
}
