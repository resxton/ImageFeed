//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 11.03.2025.
//

import UIKit

final class ProfileImageService {
    // MARK: - Public Properties
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    private var lastUsername: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var avatarURL: String?
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard username != lastUsername else {
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError - Запрос с тем же username уже выполнялся")
            fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard let profileImageRequest = makeProfileImageRequest(username: username) else {
            let error = NetworkError.invalidRequest
            print("[ProfileImageService.fetchProfileImageURL]: Ошибка создания URLRequest - \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: profileImageRequest) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.lastUsername = nil
                }
            }
            
            switch result {
            case .success(let profileImageResponse):                
                let profileImageURL = profileImageResponse.profileImage.large
                self.avatarURL = profileImageURL
                fulfillCompletionOnTheMainThread(.success(profileImageURL))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": profileImageURL])
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("[ProfileImageService.fetchProfileImageURL]: NetworkError - HTTP \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("[ProfileImageService.fetchProfileImageURL]: Ошибка выполнения запроса - \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("[ProfileImageService.fetchProfileImageURL]: Ошибка сессии URLSession")
                default:
                    print("[ProfileImageService.fetchProfileImageURL]: Неизвестная ошибка - \(error.localizedDescription)")
                }
                
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func cleanUp() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(
                string: "/users/\(username)",
                relativeTo: Constants.defaultBaseURL
              ) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = OAuth2TokenStorage().token else { return nil }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
