import ImageFeed
import Foundation

final class SpyProfileView: ProfileViewInput {
        var didUpdateProfileDetails = false
        var didUpdateAvatar = false

        var updatedName: String?
        var updatedLogin: String?
        var updatedBio: String?
        var updatedAvatarURL: URL?

        func updateProfileDetails(name: String, login: String, bio: String) {
            didUpdateProfileDetails = true
            updatedName = name
            updatedLogin = login
            updatedBio = bio
        }

        func updateAvatar(with url: URL) {
            didUpdateAvatar = true
            updatedAvatarURL = url
        }
    }
