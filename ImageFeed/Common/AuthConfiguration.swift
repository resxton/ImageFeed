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
            fatalError("Invalid URL for defaultBaseURL")
        }
    }()
    
    static let profileBaseURL: URL = {
        if let url = URL(string: "https://api.unsplash.com/me") {
            return url
        } else {
            fatalError("Invalid URL for profileBaseURL")
        }
    }()

    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            authURLString: Constants.unsplashAuthorizeURLString,
            defaultBaseURL: Constants.defaultBaseURL
        )
    }
}
