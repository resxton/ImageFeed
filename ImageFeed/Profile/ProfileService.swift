//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 08.03.2025.
//

import UIKit

final class ProfileService {
    // MARK: - Public Properties
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    private var lastToken: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let fulfillCompletionOnTheMainThread: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard token != lastToken else {
            print("[ProfileService.fetchProfile]: NetworkError - Токен уже использован")
            fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let profileRequest = makeProfileRequest(token: token) else {
            let error = NetworkError.invalidRequest
            print("[ProfileService.fetchProfile]: Ошибка создания URLRequest - \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: profileRequest) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.lastToken = nil
                }
            }
            
            switch result {
            case .success(let profileResponse):
                let profile = Profile(from: profileResponse)
                self.profile = profile
                fulfillCompletionOnTheMainThread(.success(profile))
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("[ProfileService.fetchProfile]: NetworkError - HTTP \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("[ProfileService.fetchProfile]: Ошибка выполнения запроса - \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("[ProfileService.fetchProfile]: Ошибка сессии URLSession")
                default:
                    print("[ProfileService.fetchProfile]: Неизвестная ошибка - \(error.localizedDescription)")
                }
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }

        task.resume()
    }

    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        var request = URLRequest(url: Constants.profileBaseURL)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
