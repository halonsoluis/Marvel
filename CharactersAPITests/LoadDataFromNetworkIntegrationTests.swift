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
        let sut = URLSessionHTTPClient()
        let url = MarvelURL(URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
            .url(for: 1)!

        let expect = expectation(description: "Waiting for \(url) to resolve")

        sut.get(from: url) { result in
            switch result {
            case let .success((_, response)):
                XCTAssertEqual(response.statusCode, 200)
            case let .failure(receivedError as NSError):
                XCTFail(receivedError.description)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func test_load_DataFromNetworkSingleCharacterEndpoint() {
        let sut = URLSessionHTTPClient()
        let url = MarvelURL(URL(string: "https://gateway.marvel.com:443/v1/public/characters/1011334")!)
            .url()!

        let expect = expectation(description: "Waiting for \(url) to resolve")

        sut.get(from: url) { result in
            switch result {
            case let .success((_, response)):
                XCTAssertEqual(response.statusCode, 200)
            case let .failure(receivedError as NSError):
                XCTFail(receivedError.description)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func test_load_DataFromNetworkSingleCharacterEndpoint_FailsWith404IfNotFound() {
        let sut = URLSessionHTTPClient()
        let url = MarvelURL(URL(string: "https://gateway.marvel.com:443/v1/public/characters/10113346")!)
            .url()!

        let expect = expectation(description: "Waiting for \(url) to resolve")

        sut.get(from: url) { result in
            switch result {
            case let .success((_, response)):
                XCTAssertEqual(response.statusCode, 404)
            case let .failure(receivedError as NSError):
                XCTFail(receivedError.description)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func test_load_DataFromNetworkFilteringCharacterEndpoint() {
        let sut = URLSessionHTTPClient()
        let url = MarvelURL(URL(string: "https://gateway.marvel.com:443/v1/public/characters")!)
            .url(nameStartingWith: "a")!

        let expect = expectation(description: "Waiting for \(url) to resolve")

        sut.get(from: url) { result in
            switch result {
            case let .success((_, response)):
                XCTAssertEqual(response.statusCode, 200)
            case let .failure(receivedError as NSError):
                XCTFail(receivedError.description)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }


}
