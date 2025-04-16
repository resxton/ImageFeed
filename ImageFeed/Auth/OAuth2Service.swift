//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 14.02.2025.
//

import Foundation

final class OAuth2Service {
    // MARK: - Public Properties
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard lastCode != code else {
            print("[OAuth2Service.fetchOAuthToken]: NetworkError - Код уже использован")
            fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code
        
        guard let tokenRequest = makeOAuthTokenRequest(code: code) else {
            let error = NetworkError.invalidRequest
            print("[OAuth2Service.fetchOAuthToken]: Ошибка создания URLRequest - \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: tokenRequest) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.lastCode = nil
                }
            }
            
            switch result {
            case .success(let tokenResponse):
                let token = tokenResponse.accessToken
                OAuth2TokenStorage.shared.token = token
                print("[OAuth2Service.fetchOAuthToken]: Успешно получен токен: \(tokenResponse.accessToken)")
                fulfillCompletionOnTheMainThread(.success(tokenResponse.accessToken))
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("[OAuth2Service.fetchOAuthToken]: NetworkError - HTTP \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("[OAuth2Service.fetchOAuthToken]: Ошибка выполнения запроса - \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("[OAuth2Service.fetchOAuthToken]: Ошибка сессии URLSession")
                default:
                    print("[OAuth2Service.fetchOAuthToken]: Неизвестная ошибка - \(error.localizedDescription)")
                }
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }

        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com"),
              let url = URL(
                 string: "/oauth/token"
                 + "?client_id=\(Constants.accessKey)"
                 + "&&client_secret=\(Constants.secretKey)"
                 + "&&redirect_uri=\(Constants.redirectURI)"
                 + "&&code=\(code)"
                 + "&&grant_type=authorization_code",
                 relativeTo: baseURL
              ) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post.rawValue
        return request
    }
}
