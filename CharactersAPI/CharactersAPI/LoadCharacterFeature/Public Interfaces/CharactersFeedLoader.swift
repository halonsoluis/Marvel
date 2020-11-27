//
//  CharactersFeedLoader.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public struct MarvelCharacter: Equatable {
    public let id: Int?
    public let name: String?
    public let description: String?
    public let modified: String?
    public let thumbnail: URL?
}

public typealias SingleCharacterFeedLoaderResult = (Result<MarvelCharacter?, Error>) -> Void
public typealias MultipleCharacterFeedLoaderResult = (Result<[MarvelCharacter], Error>) -> Void

public protocol CharacterFeedLoader {
    func characters(page: Int, completion: @escaping MultipleCharacterFeedLoaderResult)
    func character(id: Int, completion: @escaping SingleCharacterFeedLoaderResult)
    func search(by name: String, in page: Int, completion: @escaping MultipleCharacterFeedLoaderResult)
}
