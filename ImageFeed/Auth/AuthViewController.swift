//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    // MARK: - Public Properties
    public var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let beforeLoginSegweyID = "ShowWebView"
    
    // MARK: - Overrides
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == beforeLoginSegweyID,
           let webViewController = segue.destination as? WebViewViewController {
            webViewController.delegate = self
        }
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
                case .success(let token):
                    print("[WebViewViewController]: Успешная аутентификация, получен токен: \(token)")
                    delegate?.didAuthenticate(self)
                case .failure(let error):
                    print("[WebViewViewController]: Ошибка получения токена - \(error.localizedDescription)")
                    
                    let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
                    alert.addAction(.init(title: "ОК", style: .cancel))
                    self.present(alert, animated: true)
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
