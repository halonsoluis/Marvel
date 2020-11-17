//
//  MarverlURL.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 17/11/2020.
//

import Foundation
import CommonCrypto

struct MarverlURL {
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

extension MarverlURL {
    private struct MD5Digester {

        static func createHash(_ values: String...) -> String {
            digest(values.joined())
        }

        // return MD5 digest of string provided
        private static func digest(_ string: String) -> String {

            guard let data = string.data(using: String.Encoding.utf8) else { return "" }

            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)

            return (0..<Int(CC_MD5_DIGEST_LENGTH)).reduce("") { $0 + String(format: "%02x", digest[$1]) }
        }
    }
}
