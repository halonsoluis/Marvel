//
//  List.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

struct List<T: Summary>: Codable {

    let available: Int?
    let collectionURI: String?
    let items: [T]?
    let returned: Int?
}
