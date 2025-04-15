@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    // MARK: - WebView + AuthView
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.isLoadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        // when
        guard let url = authHelper.authURL() else {
            XCTFail()
            return
        }
        let urlString = url.absoluteString
        
        // then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // given
        guard var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native") else {
            XCTFail()
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "code", value: "test code"),
        ]
        let authHelper = AuthHelper()
        
        // when
        guard let codeUrl = components.url else {
            XCTFail()
            return
        }
        let result = authHelper.code(from: codeUrl)
        
        // then
        XCTAssertEqual(result, "test code")
    }
    
    // MARK: - Profile
    
    func testLogoutCalled() {
        // given
        let view = SpyProfileView()
        let logoutService = SpyLogoutService()
        let presenter = ProfilePresenter(
            view: view,
            logoutService: logoutService
        )
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(logoutService.didLogout)
    }
    
    func testUpdatedAvatar() {
        // given
        let view = SpyProfileView()
        let profileImageService = StubImageService()
        let profileService = StubProfileService()
        let presenter = ProfilePresenter(
            view: view,
            profileService: profileService,
            profileImageService: profileImageService
        )
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(view.didUpdateAvatar)
    }
    
    // MARK: - ImagesList
    
    
}
