//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Private Properties
    private let beforeLoginSegweyID = "ShowWebView"
    private let afterLoginSegweyID = "SuccessLogin"
    
    // MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == beforeLoginSegweyID,
           let webViewController = segue.destination as? WebViewViewController {
            webViewController.delegate = self
        }
    }
    
    // MARK: - Private Methods
    private func switchToMainScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        
        window.rootViewController = tabBarController
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            OAuth2Service.shared.fetchOAuthToken(code: code) { result in
                switch result {
                case .success(let token):
                    print("OAuth Token: \(token)")
                    self.switchToMainScreen()
                case .failure(let error):
                    print("Error fetching token: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
