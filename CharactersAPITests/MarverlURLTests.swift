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

        let url = URL(string: "www.url.com")!

        let sut = MarverlURL(
            url,
            config: MarverlURL.MarvelAPIConfig(
                itemsPerPage: 10,
                privateAPIKey: "privateAPIKey",
                publicAPIKey: "publicAPIKey"),
            hashResolver: { $0.joined() }
        )

        let expectedDate = Date()
        let expectedDateInString = expectedDate.timeIntervalSinceReferenceDate.description

        let expectedURL = URL(string: "www.url.com?offset=0&ts=\(expectedDateInString)&apikey=publicAPIKey&limit=10&hash=\(expectedDateInString)privateAPIKeypublicAPIKey")!

        let marvelURL = sut.url(for: 0, at: expectedDate)!

        XCTAssertEqual(expectedURL.pathComponents, marvelURL.pathComponents)
        XCTAssertEqual(expectedURL.baseURL, marvelURL.baseURL)
    }

    func test_includesMarvelAPIRequirementsInURLforPage1() {

        let url = URL(string: "www.url.com")!

        let sut = MarverlURL(
            url,
            config: MarverlURL.MarvelAPIConfig(
                itemsPerPage: 10,
                privateAPIKey: "privateAPIKey",
                publicAPIKey: "publicAPIKey"),
            hashResolver: { $0.joined() }
        )

        let expectedDate = Date()
        let expectedDateInString = expectedDate.timeIntervalSinceReferenceDate.description

        let expectedURL = URL(string: "www.url.com?offset=10&ts=\(expectedDateInString)&apikey=publicAPIKey&limit=10&hash=\(expectedDateInString)privateAPIKeypublicAPIKey")!

        let marvelURL = sut.url(for: 1, at: expectedDate)!

        XCTAssertEqual(expectedURL.pathComponents, marvelURL.pathComponents)
        XCTAssertEqual(expectedURL.baseURL, marvelURL.baseURL)
    }
}
