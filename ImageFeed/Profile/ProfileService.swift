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
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let fulfillCompletionOnTheMainThread: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard token != lastToken else {
            fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let profileRequest = makeProfileRequest(token: token) else {
            let error = NetworkError.invalidRequest
            print("Ошибка создания URLRequest: \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }
        
        let task = urlSession.data(for: profileRequest) { [weak self] result in
            guard let self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.lastToken = nil
                }
            }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let profileResponse = try decoder.decode(ProfileResult.self, from: data)
                    print("Успешно получен профиль: \(profileResponse)")
                    fulfillCompletionOnTheMainThread(.success(Profile(from: profileResponse)))
                } catch {
                    print("Ошибка декодирования JSON: \(error.localizedDescription)")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }

            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("Сервер вернул ошибку: HTTP \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("Ошибка выполнения запроса: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("Ошибка сессии URLSession")
                default:
                    print("Неизвестная ошибка: \(error.localizedDescription)")
                }
                
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
