//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Private Properties
    let segweyID = "ShowWebView"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segweyID,
           let webViewController = segue.destination as? WebViewViewController {
            webViewController.delegate = self
        }
    }
    
    // MARK: - IB Actions
    @IBAction func didTapLoginButton(_ sender: Any) {
        
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // TODO: process code
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
