//
//  DataWrapper.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

struct DataWrapper<T: Codable>: Codable {
    let code: Int?
    let status: String?
    let data: DataContainer<T>?
}
