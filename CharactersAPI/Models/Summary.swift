//
//  Summary.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 16/11/2020.
//

import Foundation

protocol Summary: Codable {
    var resourceURI: String? { get }
    var name: String? { get }
}

struct ComicSummary: Summary {
    let resourceURI: String? //The path to the individual comic resource.,
    let name: String? //The canonical name of the comic.
}

struct StorySummary: Summary {
    let resourceURI: String? //The path to the individual story resource.,
    let name: String? //The canonical name of the story.
    let type: String? //The type of the story (interior or cover).
}

struct EventSummary: Summary {
    let resourceURI: String? //The path to the individual event resource.,
    let name: String? //The canonical name of the event.
}

struct SeriesSummary: Summary {
    let resourceURI: String? //The path to the individual series resource.,
    let name: String? //The canonical name of the series.
}
