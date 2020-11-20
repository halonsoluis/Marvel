//
//  DataContainer.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

struct DataContainer<T: Codable>: Codable {
    let offset: Int?
    let limit: Int?
    let total: Int?
    let count: Int?
    let results: [T]?
}
