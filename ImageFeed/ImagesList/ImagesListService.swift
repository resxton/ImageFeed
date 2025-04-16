//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 20.03.2025.
//

import Foundation

final class ImagesListService {
    // MARK: - Public Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    public func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        let nextPage = (lastLoadedPage ?? 0) + 1

        let fulfillCompletionOnTheMainThread: (Result<[Photo], Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        guard nextPage != lastLoadedPage else {
            print("[ImagesListService.fetchPhotosNextPage]: Запрос с той же страницей уже выполнялся")
            fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()
        lastLoadedPage = nextPage

        guard let imagesRequest = makeImagesRequest(page: nextPage) else {
            let error = NetworkError.invalidRequest
            print("[ImagesListService.fetchPhotosNextPage]: Ошибка создания URLRequest - \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }

        let task = urlSession.objectTask(for: imagesRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.lastLoadedPage = nextPage
                }
            }

            switch result {
            case .success(let imagesResponse):
                let newPhotos = imagesResponse.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: photoResult.date,
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.large,
                        fullImageURL: photoResult.urls.full,
                        isLiked: photoResult.isLiked
                    )
                }

                let uniquePhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains { $0.id == newPhoto.id }
                }

                guard !uniquePhotos.isEmpty else {
                    print("[ImagesListService]: Загруженные фото уже есть в списке, обновление отменено")
                    return
                }

                self.photos.append(contentsOf: uniquePhotos)
                fulfillCompletionOnTheMainThread(.success(uniquePhotos))
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)


            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: Ошибка загрузки - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }

        task.resume()
    }
    
    public func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let fulfillCompletionOnTheMainThread: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        task?.cancel()
        
        guard let likeRequest = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            let error = NetworkError.invalidRequest
            print("[ImagesListService.changeLike]: Ошибка создания URLRequest - \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: likeRequest) { [weak self] (result: Result<LikePhotoResponse, Error>) in
            guard let self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                }
            }
            
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let oldPhoto = self.photos[index]
                    let updatedPhoto = Photo(
                        id: oldPhoto.id,
                        size: oldPhoto.size,
                        createdAt: oldPhoto.createdAt,
                        welcomeDescription: oldPhoto.welcomeDescription,
                        thumbImageURL: oldPhoto.thumbImageURL,
                        largeImageURL: oldPhoto.largeImageURL,
                        fullImageURL: oldPhoto.fullImageURL,
                        isLiked: !oldPhoto.isLiked
                    )
                    self.photos[index] = updatedPhoto
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                } else {
                    print("[ImagesListService.changeLike]: Фото с id \(photoId) не найдено в массиве")
                }
                
                fulfillCompletionOnTheMainThread(.success(()))
            case .failure(let error):
                print("[ImagesListService.changeLike]: Ошибка загрузки - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func cleanUp() {
        photos.removeAll()
    }
    
    // MARK: - Private Methods
    private func makeImagesRequest(page: Int?) -> URLRequest? {
        guard let url = URL(
                string: "/photos"
                + "?page=\(page ?? 1)",
                relativeTo: Constants.defaultBaseURL
              ) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.get.rawValue
        
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(
            string: "/photos/\(photoId)/like",
            relativeTo: Constants.defaultBaseURL
        ) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethods.post.rawValue : HTTPMethods.delete.rawValue

        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
#if DEBUG
    func _replacePhotos(forTesting photos: [Photo]) {
        self.photos = photos
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
#endif
}
