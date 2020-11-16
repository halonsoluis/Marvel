//
//  MarvelCharacter.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public struct MarvelCharacter: Codable {

    public let id: Int?
    public let name: String?
    public let description: String?
    public let modified: String?
    public let thumbnail: Image?
    public let resourceURI: String?

    public let comics: List<ComicSummary>?
    public let series: List<SeriesSummary>?
    public let stories: List<StorySummary>?
    public let events: List<EventSummary>?
    public let urls: [LinkURL]?
}
