import Foundation

public protocol ProfileViewOutput: AnyObject {
    func viewDidLoad()
    func didReceiveAvatarUpdate()
    func didTapLogout()
}

final class ProfilePresenter: ProfileViewOutput {
    private weak var view: ProfileViewInput?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    
    init(
        view: ProfileViewInput,
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio ?? ""
        )
        updateAvatar()
    }
    
    func didReceiveAvatarUpdate() {
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let urlString = profileImageService.avatarURL,
            let url = URL(string: urlString)
        else { return }
        
        view?.updateAvatar(with: url)
    }
    
    func didTapLogout() {
        logoutService.logout()
    }
}
