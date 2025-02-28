//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 21.02.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Methods
    private var authSegueID = "AuthFlow"
    private var gallerySegueID = "GalleryFlow"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OAuth2TokenStorage().clearToken()
        guard let token = getSavedToken() else {
            performSegue(withIdentifier: authSegueID, sender: self)
            return
        }
        
        print(token)
        performSegue(withIdentifier: gallerySegueID, sender: self)
    }
    
    // MARK: - Private Methods
    private func getSavedToken() -> String? {
        return OAuth2TokenStorage().token
    }
}
