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
}

final class ProfileTests: XCTestCase {
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
}

final class ImagesListTests: XCTestCase {
    
    // MARK: - ImagesList
    
    func testUpdatingPhotos() {
        // given
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(view: view)
        
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        
        // when
        presenter.viewDidLoad()
        
        ImagesListService.shared._replacePhotos(forTesting: [photo])
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        // then
        XCTAssertTrue(view.isUpdateTableViewCalled)
        XCTAssertEqual(view.receivedOldCount, 0)
        XCTAssertEqual(view.receivedNewPhotos?.count, 1)
        XCTAssertEqual(view.receivedNewPhotos?.first?.id, "1")
    }
    
    func testLikeButtonTap() {
        let spyView = SpyView()
        let service = ImagesListService.shared
        let presenter = ImagesListPresenter(view: spyView, service: service)
        
        let photo = Photo(id: "1", size: CGSize(width: 200, height: 300), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service._replacePhotos(forTesting: [photo])
        
        presenter.didReceivePhotosUpdate()
        
        XCTAssertEqual(presenter.photosCount, 1)
        
        let indexPath = IndexPath(row: 0, section: 0)
        presenter._didTapLike(at: indexPath)
        
        XCTAssertTrue(spyView.reloadCellCalled)
        XCTAssertEqual(spyView.reloadCellIndexPath, indexPath)
        XCTAssertTrue(spyView.reloadCellIsLiked ?? false)
    }
}
