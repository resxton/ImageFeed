//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 13.02.2025.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var backButton: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        setUpBackButton()
    }
    
    // MARK: - IB Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    // MARK: - Private Methods
    private func setUpBackButton() {
        backButton.tintColor = UIColor.ypBlack
    }
}
