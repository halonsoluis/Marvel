//
//  List.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public struct List<T: Summary>: Codable {

    public let available: Int?
    public let collectionURI: String?
    public let items: [T]?
    public let returned: Int?
}
