//
//  MarvelAPICharacterFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarvelAPICharacterFeedLoaderTests: XCTestCase {
    
    func test_load_allCharactersFromURLWhenNoIdPassed() {
        let (client, sut, time) = makeSUT()
        
        sut.characters(page: 0) { _ in }

        let requestedURL = client.requestedURL!
        let expectedURL = URL(string: "https://gateway.marvel.com:443/v1/public/characters?ts=\(time)&apikey=&hash=&limit=10&offset=0&orderBy=name")!

        XCTAssertEqual(requestedURL.host, expectedURL.host)
        XCTAssertEqual(requestedURL.relativePath, expectedURL.relativePath)
        XCTAssertEqual(requestedURL.port, 443)
        XCTAssertEqual(requestedURL.pathComponents, expectedURL.pathComponents)
    }

    func test_load_allCharactersForSecondPageFromURLWhenNoIdPassed() {
        let (client, sut, time) = makeSUT()

        sut.characters(page: 1) { _ in }

        let requestedURL = client.requestedURL!
        let expectedURL = URL(string: "https://gateway.marvel.com:443/v1/public/characters?ts=\(time)&apikey=&hash=&limit=10&offset=10&orderBy=name")!

        XCTAssertEqual(requestedURL.host, expectedURL.host)
        XCTAssertEqual(requestedURL.relativePath, expectedURL.relativePath)
        XCTAssertEqual(requestedURL.port, 443)
        XCTAssertEqual(requestedURL.pathComponents, expectedURL.pathComponents)
    }
    
    func test_load_singleCharacterFromURLWhenIdPassed() {
        let (client, sut, time) = makeSUT()
        
        sut.character(id: 1) { _ in }

        let requestedURL = client.requestedURL!
        let expectedURL = URL(string: "https://gateway.marvel.com:443/v1/public/characters/1?ts=\(time)&apikey=&hash=&limit=10&offset=0&orderBy=name")!
        
        XCTAssertEqual(requestedURL.host, expectedURL.host)
        XCTAssertEqual(requestedURL.relativePath, expectedURL.relativePath)
        XCTAssertEqual(requestedURL.port, 443)
        XCTAssertEqual(requestedURL.pathComponents, expectedURL.pathComponents)
    }
    
    func test_load_anItemFromJSONResponse() {
        let (client, sut, _) = makeSUT()
        let (response, item, _, _, _, _, _, thumbnail) = makeJSON(amountOfItems: 1)
        client.returnedJSON = response

        let expect = expectation(description: "Waiting for expectation")

        sut.character(id: 1) { result in
            switch result {
            case let .success(character) where character != nil:
                XCTAssertEqual(character!.id, item["id"] as? Int)
                XCTAssertEqual(character!.description, item["description"] as? String)
                XCTAssertEqual(character!.modified, item["modified"] as? String)
                XCTAssertEqual(character!.thumbnail?.absoluteString, "\(thumbnail["path"]!).\(thumbnail["extension"]!)")
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
        let (client, sut, _) = makeSUT()
        let (response, _, _, _, _, _, _, _) = makeJSON(amountOfItems: 10)
        client.returnedJSON = response
        let expectedError = NSError(domain: "anyerror", code: 123, userInfo: nil)
        client.returnedError = expectedError

        let expect = expectation(description: "Waiting for expectation")

        sut.characters(page: 0) { result in
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
        let (client, sut, _) = makeSUT()
        let (response, _, _, _, _, _, _, _) = makeJSON(amountOfItems: 10)
        client.returnedJSON = response

        let expect = expectation(description: "Waiting for expectation")

        sut.characters(page: 0) { result in
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

    func test_load_returnsErrorOnWrongStatusCode() {
        let (client, sut, _) = makeSUT()
        let (response, _, _, _, _, _, _, _) = makeJSON(amountOfItems: 10)
        client.returnedJSON = response
        client.returnedStatusCode = 404

        let expect = expectation(description: "Waiting for expectation")

        sut.characters(page: 0) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, loader: CharacterFeedLoader, time: String) {
        let client = HTTPClientSpy()
        let time = Date()

        func dummyHasher(values: String...) -> String {
            return ""
        }
        
        let sut = MarvelAPICharacterFeedLoader(urlDecorator: MarvelURL(
            URL(string: "https://gateway.marvel.com:443/v1/public/")!,
            config: MarvelAPIConfig(itemsPerPage: 10, privateAPIKey: "", publicAPIKey: ""),
            hashResolver: dummyHasher,
            timeProvider: { time }
        ), client: client)

        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "Potential memory leak", file: file, line: line)
        }
        
        return (client: client, loader: sut, time: time.timeIntervalSinceReferenceDate.description)
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
