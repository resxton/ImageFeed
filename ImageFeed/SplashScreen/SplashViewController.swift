import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private var authSegueID = "AuthFlow"
    private var gallerySegueID = "GalleryFlow"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let splashScreenImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        return imageView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        setupVC()
        setupUI()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard OAuth2TokenStorage.shared.token != nil else {
            presentAuthScreen()
            return
        }
        presentGalleryScreen()
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func setupVC() {
        view.backgroundColor = UIColor.ypBlack
    }
    
    private func setupUI() {
        view.addSubview(splashScreenImageView)
        splashScreenImageView.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // SplashScreenLogo
            splashScreenImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenImageView.widthAnchor.constraint(equalToConstant: 73),
            splashScreenImageView.heightAnchor.constraint(equalToConstant: 76),
            splashScreenImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 228)
        ])
    }
}

extension SplashViewController {
    private func presentAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("Не удалось создать AuthViewController")
        }

        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    private func presentGalleryScreen() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[SplashViewController.presentGalleryScreen]: токен отсутствует")
            return
        }
        
        fetchProfile(token)
    }
    
    private func presentAlert(title: String, message: String?, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(.init(title: "ОК", style: .cancel))
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                guard let username = profileService.profile?.username else {
                    print("[SplashViewController]: Ошибка — username не найден")
                    return
                }
                
                profileImageService.fetchProfileImageURL(username: username) { result in
                    switch result {
                    case .success(_):
                        print()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure:
                print("Ошибка получения профиля")
                presentAlert(title: "Что-то пошло не так(",
                             message: "Не удалось войти в систему",
                             preferredStyle: .alert)
                break
            }
        }
    }
}
