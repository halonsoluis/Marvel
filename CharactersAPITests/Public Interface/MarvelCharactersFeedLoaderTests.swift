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
        stubHTTPResponseAndData(itemAmount: 10, statusCode: 200)

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
        stubHTTPResponseAndData(itemAmount: 10, statusCode: 200)

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
        stubHTTPResponseAndData(itemAmount: 1, statusCode: 200)

        let expect = expectation(description: "A request for data to the network was issued")

        sut.character(id: 0) { result in
            switch result {
            case let .success(item):
                let jsonItem = self.makeValidJSONResponse(amountOfItems: 1, statusCode: 200).item

                XCTAssertEqual(item?.name, jsonItem["name"] as? String)
                XCTAssertEqual(item?.description, jsonItem["description"] as? String)
                XCTAssertEqual(item?.id, jsonItem["id"] as? Int)
                XCTAssertEqual(item?.modified, jsonItem["modified"] as? String)
            default:
                XCTFail("Unexpected state, expected success received \(result)")
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    func test_singleCharacterWithUnknownIdAndValidResponse_doesNotProduceAMarvelItem() {
        let sut = makeSUT()
        stubHTTPResponseAndData(itemAmount: 0, statusCode: 200)

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

    private func stubHTTPResponseAndData(itemAmount: Int, statusCode: Int = 200) {
        let data: Data = try! JSONSerialization.data(
            withJSONObject: makeValidJSONResponse(amountOfItems: itemAmount, statusCode: statusCode).response,
            options: .prettyPrinted
        )
        let response = HTTPURLResponse(url: URL(string: "www.anyurl.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)

        URLProtocolStub.stub(data: data, response: response, error: nil)
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
