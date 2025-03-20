//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Сомов Кирилл on 14.02.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
}

extension URLSession {
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                if (200..<300).contains(statusCode) {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[URLSession.data]: HTTP ошибка \(statusCode) - Данные: \(String(data: data, encoding: .utf8) ?? "nil")")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[URLSession.data]: Ошибка запроса - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[URLSession.data]: Ошибка сессии URLSession")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }

        return task
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    print("[URLSession.objectTask]: Успешно декодировано: \(decodedResponse)")
                    completion(.success(decodedResponse))
                } catch {
                    print("[URLSession.objectTask]: Ошибка декодирования - \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[URLSession.objectTask]: Ошибка сети - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
