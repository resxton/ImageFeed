import Foundation
 
public protocol ImagesListViewOutput: AnyObject {
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

final class ImagesListPresenter {
    weak var view: ImagesListViewInput?
    private let imagesListService: ImagesListService
    private var photos: [Photo] = []

    init(view: ImagesListViewInput, service: ImagesListService = ImagesListService.shared) {
        self.view = view
        self.imagesListService = service
    }
}

extension ImagesListPresenter: ImagesListViewOutput {
    var photosCount: Int {
        return photos.count
    }

    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePhotosUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

        imagesListService.fetchPhotosNextPage { _ in }
    }

    @objc func didReceivePhotosUpdate() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos

        guard newPhotos.count > oldCount else { return }

        let added = Array(newPhotos.suffix(from: oldCount))
        photos.append(contentsOf: added)

        view?.updateTableView(oldCount: oldCount, newPhotos: added)
    }

    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }

    func willDisplayCell(at indexPath: IndexPath) {
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        if !testMode {
            if indexPath.row == photos.count - 1 {
                imagesListService.fetchPhotosNextPage { _ in }
            }
        }
    }

    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        #if DEBUG
        view?.reloadCell(at: indexPath, isLiked: !photo.isLiked)
        return
        #endif
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.reloadCell(at: indexPath, isLiked: self.photos[indexPath.row].isLiked)
            case .failure:
                break
            }
        }
    }
}
