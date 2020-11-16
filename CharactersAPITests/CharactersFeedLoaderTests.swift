//
//  CharactersFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
import CharactersAPI

class CharactersFeedLoaderTests: XCTestCase {
    
    func testInit_doesNot_requestDataFromURL() {
        let (client, _) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_allCharactersFromURLWhenNoIdPassed() {
        let (client, sut) = makeSUT()
        
        sut.load(id: nil) { _ in }
        
        XCTAssertEqual(client.requestedURL, URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
    }
    
    func test_load_allCharactersFromCustomURLWhenNoIdPassed() {
        let client = HTTPClientSpy()
        let sut = MarvelAPICharacterFeedLoader(baseAPIURL: URL(string: "www.example.com")!, client: client)
        
        sut.load(id: nil) { _ in }
        
        XCTAssertEqual(client.requestedURL, URL(string: "www.example.com/characters")!)
    }
    
    func test_load_singleCharacterFromURLWhenIdPassed() {
        let (client, sut) = makeSUT()
        
        sut.load(id: 1) { _ in }
        
        XCTAssertEqual(client.requestedURL, URL(string: "https://gateway.marvel.com:443/v1/public/characters/1")!)
    }
    
    func test_load_anItemFromJSONResponse() {
        let (client, sut) = makeSUT()
        let (response, item, _, _, _, _, _, thumbnail) = makeJSON(amountOfItems: 1)
        client.returnedJSON = response

        let expect = expectation(description: "Waiting for expectation")

        sut.load(id: 1) { result in
            switch result {
            case let .success(characters) where characters.count == 1:
                let character = characters.first!

                XCTAssertEqual(character.id, item["id"] as? Int)
                XCTAssertEqual(character.description, item["description"] as? String)
                XCTAssertEqual(character.modified, item["modified"] as? String)
                XCTAssertEqual(character.thumbnail?.absoluteString, "\(thumbnail["path"]!).\(thumbnail["extension"]!)")
            case .failure:
                XCTFail()
            case .success(_):
                XCTFail()
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }

    func test_load_onFailure_FailsWithError() {
        let (client, sut) = makeSUT()
        let (response, _, _, _, _, _, _, _) = makeJSON(amountOfItems: 10)
        client.returnedJSON = response
        let expectedError = NSError(domain: "anyerror", code: 123, userInfo: nil)
        client.returnedError = expectedError

        let expect = expectation(description: "Waiting for expectation")

        sut.load(id: nil) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(receivedError as NSError):
                XCTAssertEqual(expectedError.domain, receivedError.domain)
                XCTAssertEqual(expectedError.code, receivedError.code)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }

    func test_load_severalItemsFromJSONResponse() {
        let (client, sut) = makeSUT()
        let (response, _, _, _, _, _, _, _) = makeJSON(amountOfItems: 10)
        client.returnedJSON = response

        let expect = expectation(description: "Waiting for expectation")

        sut.load(id: nil) { result in
            switch result {
            case let .success(characters):
                XCTAssertEqual(characters.count, 10)
            case .failure:
                XCTFail()
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
    
    private func makeSUT() -> (client: HTTPClientSpy, loader: CharacterFeedLoader) {
        let client = HTTPClientSpy()
        let sut = MarvelAPICharacterFeedLoader(client: client)
        
        return (client: client, loader: sut)
    }
    
    private func makeJSON(amountOfItems: Int) -> (response: [String: Any], item: [String: Any], urls: [[String: String]], events: [String: Any], comics: [String: Any], series: [String: Any], stories: [String: Any], thumbnail: [String: String]) {
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

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    var returnedJSON: [String: Any]?
    var returnedError: Error?
    var returnedStatusCode: Int = 200
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        requestedURL = url

        if let returnedError = returnedError {
            completion(.failure(returnedError))
            return
        }

        if let returnedJSON = returnedJSON {
            let data = try! JSONSerialization.data(withJSONObject: returnedJSON)
            completion(.success((data, HTTPURLResponse(url: url, statusCode: returnedStatusCode, httpVersion: nil, headerFields: nil)!)))
        }
    }
}
