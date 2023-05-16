//
//  XCTestCase+MakeValidJsonResponse.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 19/11/2020.
//

import XCTest

extension XCTestCase {
    func makeValidJSONResponse(amountOfItems: Int, statusCode: Int = 200) -> (response: [String: Any], item: [String: Any], urls: [[String: String]], thumbnail: [String: String]) {
        let thumbnail: [String: String] = [
            "path": "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784",
            "extension": "jpg"
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
            "urls": urls
        ]

        let response: [String: Any] = [
            "code": statusCode,
            "status": "Ok",
            "data": [
                "offset": 0,
                "limit": 20,
                "total": 1485,
                "count": amountOfItems,
                "results": Array(repeating: item, count: amountOfItems)
            ] as [String : Any]
        ]
        return (response, item, urls, thumbnail)
    }

    func makeValidJSONResponse(publicationAmount: Int, statusCode: Int = 200) -> (response: [String: Any], item: [String: Any], thumbnail: [String: String]) {
        let thumbnail: [String: String] = [
            "path": "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784",
            "extension": "jpg"
        ]

        let item: [String: Any] = [
            "id": 50769,
            "digitalId": 0,
            "title": "Original Sin (2014) #6 (Dell'otto Variant)",
            "issueNumber": 6,
            "variantDescription": "Dell'otto Variant",
            "description": "Who Pulled The Trigger?",
            "modified": "2014-07-08T16:45:06-0400",
            "isbn": "",
            "upc": "75960608034200621",
            "diamondCode": "",
            "ean": "",
            "issn": "",
            "format": "Comic",
            "pageCount": 32,
            "thumbnail": thumbnail
        ]

        let response: [String: Any] = [
            "code": statusCode,
            "status": "Ok",
            "data": [
                "offset": 0,
                "limit": 20,
                "total": 33,
                "count": publicationAmount,
                "results": Array(repeating: item, count: publicationAmount)
            ] as [String : Any]
        ]
        return (response, item, thumbnail)
    }
}
