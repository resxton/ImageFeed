//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Public Properties
    public var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let beforeLoginSegweyID = "ShowWebView"
    
    // MARK: - Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == beforeLoginSegweyID {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(beforeLoginSegweyID)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    private func presentAlert(title: String, message: String?, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(.init(title: "ОК", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            UIBlockingProgressHUD.show()
            
            OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
                guard let self else { return }
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(_):
                    delegate?.didAuthenticate(self)
                case .failure(let error):
                    print("[WebViewViewController]: Ошибка получения токена - \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Что-то пошло не так(",
                                     message: "Не удалось войти в систему",
                                     preferredStyle: .alert)
                    }
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

// MARK: - AuthViewControllerDelegate
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
