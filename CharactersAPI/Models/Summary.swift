//
//  Summary.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

public protocol Summary: Codable {
    var resourceURI: String? { get }
    var name: String? { get }
}

public struct ComicSummary: Summary {
    public let resourceURI: String? //The path to the individual comic resource.,
    public let name: String? //The canonical name of the comic.
}

public struct StorySummary: Summary {
    public let resourceURI: String? //The path to the individual story resource.,
    public let name: String? //The canonical name of the story.
    public let type: String? //The type of the story (interior or cover).
}

public struct EventSummary: Summary {
    public let resourceURI: String? //The path to the individual event resource.,
    public let name: String? //The canonical name of the event.
}

public struct SeriesSummary: Summary {
    public let resourceURI: String? //The path to the individual series resource.,
    public let name: String? //The canonical name of the series.
}
