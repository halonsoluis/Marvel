//
//  MarverlURLTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 17/11/2020.
//

import XCTest
@testable import CharactersAPI

class MarverlURLTests: XCTestCase {
    func test_includesMarvelAPIRequirementsInURL() {
        let expectedDate = Date()
        let url = URL(string: "www.url.com")!

        let sut = MarvelURL(
            url,
            config: MarvelAPIConfig(
                itemsPerPage: 10,
                privateAPIKey: "privateAPIKey",
                publicAPIKey: "publicAPIKey"),
            hashResolver: { $0.joined() },
            timeProvider: { expectedDate }
        )

        let expectedDateInString = expectedDate.timeIntervalSinceReferenceDate.description

        let expectedURL = URL(string: "www.url.com/characters?offset=0&ts=\(expectedDateInString)&apikey=publicAPIKey&limit=10&hash=\(expectedDateInString)privateAPIKeypublicAPIKey")!

        let marvelURL = sut.url(route: .characters, for: 0)!

        XCTAssertEqual(expectedURL.pathComponents, marvelURL.pathComponents)
        XCTAssertEqual(expectedURL.baseURL, marvelURL.baseURL)
    }

    func test_includesMarvelAPIRequirementsInURLforPage1() {

        let url = URL(string: "www.url.com" )!
        let expectedDate = Date()

        let sut = MarvelURL(
            url,
            config: MarvelAPIConfig(
                itemsPerPage: 10,
                privateAPIKey: "privateAPIKey",
                publicAPIKey: "publicAPIKey"),
            hashResolver: { $0.joined() },
            timeProvider: { expectedDate }
        )

        let expectedDateInString = expectedDate.timeIntervalSinceReferenceDate.description

        let expectedURL = URL(string: "www.url.com/characters?offset=10&ts=\(expectedDateInString)&apikey=publicAPIKey&limit=10&hash=\(expectedDateInString)privateAPIKeypublicAPIKey")!

        let marvelURL = sut.url(route: .characters, for: 1)!

        XCTAssertEqual(expectedURL.pathComponents, marvelURL.pathComponents)
        XCTAssertEqual(expectedURL.baseURL, marvelURL.baseURL)
    }
}
