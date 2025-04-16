import ImageFeed

final class ImagesListServiceMock {
    var photos: [Photo] {
        get { return mockPhotos }
        set { mockPhotos = newValue }
    }

    var mockPhotos: [Photo] = []
    var isChangeLikeCalled = false

    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        isChangeLikeCalled = true
        completion(.success(()))
    }
}
