//
//  LinkURL.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

struct LinkURL: Codable {
    let type: String?
    let url: String?
}

extension LinkURL {
    var resolvedURL: URL? {
        guard let url = url, let type = type else {
            return nil
        }
        return URL(string: "\(url).\(type)")
    }
}
