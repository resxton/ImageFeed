//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 14.02.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
