//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 21.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private var authSegueID = "AuthFlow"
    private var gallerySegueID = "GalleryFlow"
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // OAuth2TokenStorage().clearToken()
        
        guard storage.token != nil else {
            performSegue(withIdentifier: authSegueID, sender: self)
            return
        }
        
        performSegue(withIdentifier: gallerySegueID, sender: self)
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
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == authSegueID {
            guard let viewController = segue.destination as? AuthViewController else {
                assertionFailure("Failed to prepare for \(authSegueID)")
                return
            }
            
            viewController.delegate = self
        } else if segue.identifier == gallerySegueID {
            guard let token = storage.token else {
                return
            }
            
            fetchProfile(token)
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
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
                self.switchToTabBarController()
            case .failure:
                // TODO: [Sprint 11] Покажите ошибку получения профиля
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
