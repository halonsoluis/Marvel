//
//  MarvelAPIConfig.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 17/11/2020.
//

import Foundation

struct MarvelAPIConfig {
    var itemsPerPage: Int
    var privateAPIKey: String
    var publicAPIKey: String

    static var shared: MarvelAPIConfig {
        MarvelAPIConfig(
            itemsPerPage: 20,
            privateAPIKey: "da9b58ab629e94bb1d66ea165fe1fe92c896ba08",
            publicAPIKey: "19972fbcfc8ba75736070bc42fbca671"
        )
    }
}
