//
//  MarvelCharactersFeedLoaderTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 18/11/2020.
//

import XCTest
import CharactersAPI

//Integration test to verify end2end system work as expected
class MarvelCharactersFeedLoaderTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        URLProtocolStub.startIntercepting()
    }

    func test_charactersCallWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 10)
        let data: Data = try! JSONSerialization.data(withJSONObject: response.response, options: .prettyPrinted)
        URLProtocolStub.stub(data: data, response: URLResponse(url: URL(string: "www.anyurl.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), error: nil)

        let expect = expectation(description: "A request for data to the network was issued")

        sut.characters(page: 0) { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items.count, 10)
            default:
                break
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    func test_searchWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 10)
        let data: Data = try! JSONSerialization.data(withJSONObject: response.response, options: .prettyPrinted)
        URLProtocolStub.stub(data: data, response: HTTPURLResponse(url: URL(string: "www.anyurl.com")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        let expect = expectation(description: "A request for data to the network was issued")

        sut.search(by: "", in : 0) { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items.count, 10)
            default:
                XCTFail("Unexpected state, expected success received \(result)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    func test_singleCharacterWithValidResponse_producesAMarvelItem() {
        let sut = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 1)
        let data: Data = try! JSONSerialization.data(withJSONObject: response.response, options: .prettyPrinted)
        URLProtocolStub.stub(data: data, response: HTTPURLResponse(url: URL(string: "www.anyurl.com")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        let expect = expectation(description: "A request for data to the network was issued")

        sut.character(id: 0) { result in
            switch result {
            case let .success(item):
                XCTAssertEqual(item?.name, response.item["name"] as? String)
                XCTAssertEqual(item?.description, response.item["description"] as? String)
                XCTAssertEqual(item?.id, response.item["id"] as? Int)
                XCTAssertEqual(item?.modified, response.item["modified"] as? String)
            default:
                XCTFail("Unexpected state, expected success received \(result)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    func test_singleCharacterWithUnknownIdAndValidResponse_doesNotProduceAMarvelItem() {
        let sut = makeSUT()
        let response = makeValidJSONResponse(amountOfItems: 0)
        let data: Data = try! JSONSerialization.data(withJSONObject: response.response, options: .prettyPrinted)
        URLProtocolStub.stub(data: data, response: HTTPURLResponse(url: URL(string: "www.anyurl.com")!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        let expect = expectation(description: "A request for data to the network was issued")

        sut.character(id: 0) { result in
            switch result {
            case let .success(item):
                XCTAssertNil(item)
            default:
                XCTFail("Unexpected state, expected success received \(result)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    private func makeSUT() -> CharacterFeedLoader {
        let client = URLSessionHTTPClient()
        let sut = MarvelCharactersFeedLoader(client: client)

        return sut
    }

    override class func tearDown() {
        super.tearDown()

        URLProtocolStub.stopIntercepting()
    }
}
