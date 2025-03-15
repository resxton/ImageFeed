//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 21.02.2025.
//

import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private var authSegueID = "AuthFlow"
    private var gallerySegueID = "GalleryFlow"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let splashScreeImageView: UIImageView = {
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
#warning("Remove comments")
//        guard KeychainWrapper.standard.string(forKey: "Auth token") != nil else {
//            presentAuthScreen()
//            return
//        }
        
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
        view.addSubview(splashScreeImageView)
        splashScreeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // SplashScreenLogo
            splashScreeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreeImageView.widthAnchor.constraint(equalToConstant: 73),
            splashScreeImageView.heightAnchor.constraint(equalToConstant: 76),
            splashScreeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 228)
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
        guard let token = KeychainWrapper.standard.string(forKey: "Auth token") else {
            print("[SplashViewController.presentGalleryScreen]: токен отсутствует")
            return
        }
        fetchProfile(token)
        switchToTabBarController()
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = KeychainWrapper.standard.string(forKey: "Auth token") else {
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure:
                print("Ошибка получения профиля")
                break
            }
        }
        
        guard let username = profileService.profile?.username else {
            return
        }
        
        profileImageService.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
