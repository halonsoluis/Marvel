//
//  HTTPClientSpy.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 18/11/2020.
//

import Foundation
import CharactersAPI

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    var returnedJSON: [String: Any]?
    var returnedError: Error?
    var returnedStatusCode: Int = 200

    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        requestedURL = url

        if let returnedError = returnedError {
            completion(.failure(returnedError))
            return
        }

        if let returnedJSON = returnedJSON {
            let data = try! JSONSerialization.data(withJSONObject: returnedJSON)
            completion(.success((data, HTTPURLResponse(url: url, statusCode: returnedStatusCode, httpVersion: nil, headerFields: nil)!)))
        }
    }
}
