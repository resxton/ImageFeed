import ImageFeed
import Foundation

final class ImagesListViewSpy: ImagesListViewInput {
    var isUpdateTableViewCalled = false
    var receivedOldCount: Int?
    var receivedNewPhotos: [Photo]?
    
    func updateTableView(oldCount: Int, newPhotos: [Photo]) {
        print(oldCount, newPhotos.count)
        isUpdateTableViewCalled = true
        receivedOldCount = oldCount
        receivedNewPhotos = newPhotos
    }
    
    func reloadCell(at indexPath: IndexPath, isLiked: Bool) {}
}
