//
//  MarvelURL.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 17/11/2020.
//

import Foundation

struct MarvelURL {
    private let baseURL: URL
    private let config: MarvelAPIConfig
    private let hashResolver: (String...) -> String

    internal init(_ baseURL: URL, config: MarvelAPIConfig = .shared, hashResolver: @escaping (String...) -> String = MD5Digester.createHash) {
        self.baseURL = baseURL
        self.config = config
        self.hashResolver = hashResolver
    }

    func url(for page: Int = 0, at time: Date = Date()) -> URL? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = params(for: page, at: time, using: hashResolver).map(URLQueryItem.init)
        return components.url
    }

    private func params(for page: Int = 0, at time: Date, using hashResolver: (String...) -> String) -> [String: String] {
        let (offset, limit) = pagination(for: max(page, 0), itemsPerPage: config.itemsPerPage)
        let timestamp = time.timeIntervalSinceReferenceDate.description
        return [
            "apikey": config.publicAPIKey,
            "hash" : hashResolver(timestamp, config.privateAPIKey, config.publicAPIKey),
            "ts" : timestamp,
            "limit" : limit.description,
            "offset" : offset.description,
        ]
    }

    private func pagination(for page: Int, itemsPerPage: Int) -> (offset: Int, limit: Int) {
        (offset: page * itemsPerPage, limit : itemsPerPage)
    }
}
