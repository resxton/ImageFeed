//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {
    // MARK: - Public Properties
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - IB Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func viewDidLoad() {
        webView.navigationDelegate = self
        setUpBackButton()
        setUpProgressView()
        loadAuthView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // MARK: - Overrides Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - IB Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    
    // MARK: - Private Methods
    private func setUpBackButton() {
        backButton.tintColor = UIColor.ypBlack
    }
    
    private func setUpProgressView() {
        progressView.tintColor = UIColor.ypBlack
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
        print(webView.estimatedProgress)
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
