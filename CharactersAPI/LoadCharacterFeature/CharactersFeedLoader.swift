//
//  CharactersFeedLoader.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public struct MarvelCharacter {
    public let id: Int?
    public let name: String?
    public let description: String?
    public let modified: String?
    public let thumbnail: URL?
}

public protocol CharacterFeedLoader {
    func load(id: Int?, completion: @escaping (Result<[MarvelCharacter], Error>) -> Void)
  //  func search(byName: String, completion: @escaping (Result<[MarvelCharacter], Error>) -> Void)
}
