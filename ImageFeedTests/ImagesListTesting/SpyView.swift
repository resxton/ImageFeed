import ImageFeed
import Foundation

class SpyView: ImagesListViewInput {
    var updateTableViewCalled = false
    var reloadCellCalled = false
    var reloadCellIndexPath: IndexPath?
    var reloadCellIsLiked: Bool?
    
    func updateTableView(oldCount: Int, newPhotos: [Photo]) {
        updateTableViewCalled = true
    }
    
    func reloadCell(at indexPath: IndexPath, isLiked: Bool) {
        reloadCellCalled = true
        reloadCellIndexPath = indexPath
        reloadCellIsLiked = isLiked
    }
}
