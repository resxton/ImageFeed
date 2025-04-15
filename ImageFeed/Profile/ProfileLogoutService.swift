import Foundation
import WebKit
import UIKit

public protocol ProfileLogoutServiceProtocol: AnyObject {
    func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanCookies()
        OAuth2TokenStorage.shared.clearToken()
        ProfileService.shared.cleanUp()
        ProfileImageService.shared.cleanUp()
        ImagesListService.shared.cleanUp()
        
        switchToSplashScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}
