//
//  URLSessionHTTPClient.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 17/11/2020.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }
        }.resume()
    }
}
