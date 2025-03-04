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
    let storage = OAuth2TokenStorage()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let tokenRequest = makeOAuthTokenRequest(code: code) else {
            let error = NetworkError.invalidRequest
            print("Ошибка создания URLRequest: \(error)")
            fulfillCompletionOnTheMainThread(.failure(error))
            return
        }
        
        let task = URLSession.shared.data(for: tokenRequest) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.storage.token = tokenResponse.accessToken
                    print("Успешно получен токен: \(tokenResponse.accessToken)")
                    fulfillCompletionOnTheMainThread(.success(tokenResponse.accessToken))
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
        request.httpMethod = "POST"
        return request
    }
}
