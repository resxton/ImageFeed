import ImageFeed
import XCTest

class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var isLoadRequestCalled = false
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    
    func load(request: URLRequest) {
        isLoadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
