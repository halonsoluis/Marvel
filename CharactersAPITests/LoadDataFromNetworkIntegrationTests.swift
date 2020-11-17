//
//  LoadDataFromNetworkIntegrationTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 17/11/2020.
//

import XCTest
@testable import CharactersAPI

class LoadDataFromNetworkIntegrationTests: XCTestCase {

    func test_load_DataFromNetwork() {
        let (sut, marvelURL) = createSUT( "https://gateway.marvel.com:443/v1/public/characters")
        let url = marvelURL.url(for: 1)!

        expectToResolve(url: url, sut: sut, with: 200)
    }

    func test_load_DataFromNetworkSingleCharacterEndpoint() {
        let (sut, marvelURL) = createSUT( "https://gateway.marvel.com:443/v1/public/characters/1011334")
        let url = marvelURL.url()!

        expectToResolve(url: url, sut: sut, with: 200)
    }

    func test_load_DataFromNetworkSingleCharacterEndpoint_FailsWith404IfNotFound() {
        let (sut, marvelURL) = createSUT( "https://gateway.marvel.com:443/v1/public/characters/10113346")
        let url = marvelURL.url()!

        expectToResolve(url: url, sut: sut, with: 404)
    }

    func test_load_DataFromNetworkFilteringCharacterEndpoint() {
        let (sut, marvelURL) = createSUT("https://gateway.marvel.com:443/v1/public/characters")
        let url = marvelURL.url(nameStartingWith: "a")!

        expectToResolve(url: url, sut: sut, with: 200)
    }

    func expectToResolve(url: URL, sut: HTTPClient, with statusCode: Int, file: StaticString = #filePath, line: UInt = #line) {
        let expect = expectation(description: "Waiting for \(url) to resolve")

        sut.get(from: url) { result in
            switch result {
            case let .success((_, response)):
                XCTAssertEqual(response.statusCode, statusCode)
            case let .failure(receivedError as NSError):
                XCTFail(receivedError.description)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func createSUT(_ urlString: String) -> (HTTPClient, MarvelURL) {
        let sut = URLSessionHTTPClient()
        let url = MarvelURL(URL(string: urlString)!, config: .shared, hashResolver: MarvelURL.MD5Digester.createHash, timeProvider: Date.init)

        return (sut, url)
    }
}
