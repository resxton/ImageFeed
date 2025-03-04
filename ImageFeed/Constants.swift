//
//  Constants.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import Foundation

enum Constants {
    static let accessKey = "oq72chMZPZfGXAV4aU8wTHjiKP1rEVCSf2PcdtNONtc"
    static let secretKey = "qrc_Jy1jPv0Eczhjv39_Mg1l6a5BYPKq86KUftPaRr4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        if let url = URL(string: "https://api.unsplash.com") {
            return url
        } else {
            fatalError("Invalid URL for defaultBaseURL") // Или можно использовать другое поведение
        }
    }()
}
