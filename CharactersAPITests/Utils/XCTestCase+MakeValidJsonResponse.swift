//
//  XCTestCase+MakeValidJsonResponse.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 19/11/2020.
//

import XCTest

extension XCTestCase {
    func makeValidJSONResponse(amountOfItems: Int) -> (response: [String: Any], item: [String: Any], urls: [[String: String]], events: [String: Any], comics: [String: Any], series: [String: Any], stories: [String: Any], thumbnail: [String: String]) {
        let thumbnail: [String: String] = [
            "path": "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784",
            "extension": "jpg"
        ]

        let comics: [String: Any] = [
            "available": 2,
            "collectionURI": "http://gateway.marvel.com/v1/public/characters/1011334/comics",
            "items": [
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/comics/21366",
                    "name": "Avengers: The Initiative (2007) #14"
                ],
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/comics/24571",
                    "name": "Avengers: The Initiative (2007) #14 (SPOTLIGHT VARIANT)"
                ],
            ],
            "returned": 2
        ]

        let series: [String: Any] = [
            "available": 2,
            "collectionURI": "http://gateway.marvel.com/v1/public/characters/1011334/series",
            "items": [
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/series/1945",
                    "name": "Avengers: The Initiative (2007 - 2010)"
                ],
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/series/2045",
                    "name": "Marvel Premiere (1972 - 1981)"
                ]
            ],
            "returned": 2
        ]

        let stories: [String: Any] = [
            "available": 2,
            "collectionURI": "http://gateway.marvel.com/v1/public/characters/1011334/stories",
            "items": [
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/stories/19947",
                    "name": "Cover #19947",
                    "type": "cover"
                ],
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/stories/19948",
                    "name": "The 3-D Man!",
                    "type": "interiorStory"
                ],
            ],
            "returned": 2
        ]

        let events: [String: Any] = [
            "available": 1,
            "collectionURI": "http://gateway.marvel.com/v1/public/characters/1011334/events",
            "items": [
                [
                    "resourceURI": "http://gateway.marvel.com/v1/public/events/269",
                    "name": "Secret Invasion"
                ]
            ],
            "returned": 1
        ]

        let urls: [[String: String]] = [
            [
                "type": "detail",
                "url": "http://marvel.com/characters/74/3-d_man?utm_campaign=apiRef&utm_source=19972fbcfc8ba75736070bc42fbca671"
            ],
            [
                "type": "wiki",
                "url": "http://marvel.com/universe/3-D_Man_(Chandler)?utm_campaign=apiRef&utm_source=19972fbcfc8ba75736070bc42fbca671"
            ],
            [
                "type": "comiclink",
                "url": "http://marvel.com/comics/characters/1011334/3-d_man?utm_campaign=apiRef&utm_source=19972fbcfc8ba75736070bc42fbca671"
            ]
        ]

        let item: [String: Any] = [
            "id": 1011334,
            "name": "3-D Man",
            "description": "A description for 3D Man",
            "modified": "2014-04-29T14:18:17-0400",
            "thumbnail": thumbnail,
            "resourceURI": "http://gateway.marvel.com/v1/public/characters/1011334",

            "comics": comics,
            "series": series,
            "stories": stories,
            "events": events,
            "urls": urls
        ]

        let response: [String: Any] = [
            "code": 200,
            "status": "Ok",
            "data": [
                "offset": 0,
                "limit": 20,
                "total": 1485,
                "count": amountOfItems,
                "results": Array(repeating: item, count: amountOfItems)
            ]
        ]
        return (response, item, urls, events, comics, series, stories, thumbnail)
    }
}
