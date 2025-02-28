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
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
        print("changed root to tabbar")
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
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
        // performSegue(withIdentifier: gallerySegueID, sender: self)
    }
}
