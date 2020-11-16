//
//  NonCharacterItem.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

struct NonCharacterItem: Codable {
    let id: Int?
    let title: String?
    let modified: String?
    let thumbnail: Image?
    let resourceURI: String?
}
