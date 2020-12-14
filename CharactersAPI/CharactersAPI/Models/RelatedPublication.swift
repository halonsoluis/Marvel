//
//  RelatedPublication.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 08/12/2020.
//

import Foundation

struct RelatedPublication: Codable {
    let id: Int?
    let title: String?
    let modified: String?
    let thumbnail: Image?
    let resourceURI: String?
}
