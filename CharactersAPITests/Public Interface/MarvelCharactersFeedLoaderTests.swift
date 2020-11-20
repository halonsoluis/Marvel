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
        stubHTTPResponseAndData(itemAmount: 10, statusCode: 200)

        let items = extractResultDataFromCall(result: performCharactersRequest(page: 0, using: makeSUT()))!
        XCTAssertEqual(items.count, 10)
    }

    func test_searchWithValidResponse_producesMarvelItems() {
        stubHTTPResponseAndData(itemAmount: 10, statusCode: 200)

        let items = extractResultDataFromCall(result: performSearchRequest(name: "", page: 0, using: makeSUT()))!
        XCTAssertEqual(items.count, 10)
    }

    func test_singleCharacterWithValidResponse_producesAMarvelItem() {
        stubHTTPResponseAndData(itemAmount: 1, statusCode: 200)

        let item = extractResultDataFromCall(result: performCharacterRequest(using: makeSUT()))!
        let jsonItem = makeValidJSONResponse(amountOfItems: 1, statusCode: 200).item

        XCTAssertEqual(item!.name, jsonItem["name"] as? String)
        XCTAssertEqual(item!.description, jsonItem["description"] as? String)
        XCTAssertEqual(item!.id, jsonItem["id"] as? Int)
        XCTAssertEqual(item!.modified, jsonItem["modified"] as? String)
    }

    func test_singleCharacterWithUnknownIdAndValidResponse_doesNotProduceAMarvelItem() {
        stubHTTPResponseAndData(itemAmount: 0, statusCode: 404)

        switch performCharacterRequest(using: makeSUT()) {
        case let .success(item):
            XCTAssertNil(item)
        default:
            XCTFail("This is expected to receive a nil item as a response to a not found id")
        }
    }

    func test_singleCharacterResponseWithNonValidStatusCodeProducesAnError() {
        [403, 405, 406, 300, 500].forEach { statusCode in
            stubHTTPResponseAndData(itemAmount: 0, statusCode: statusCode)

            switch performCharacterRequest(using: makeSUT()) {
            case .failure:
                break;
            default:
                XCTFail("This is expected to receive an error as the status code is not handled")
            }
        }
    }

    private func stubHTTPResponseAndData(itemAmount: Int, statusCode: Int = 200) {
        let data: Data = try! JSONSerialization.data(
            withJSONObject: makeValidJSONResponse(amountOfItems: itemAmount, statusCode: statusCode).response,
            options: .prettyPrinted
        )
        let response = HTTPURLResponse(url: URL(string: "www.anyurl.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)

        URLProtocolStub.stub(data: data, response: response, error: nil)
    }

    private func extractResultDataFromCall<T>(result: Result<T, Error>, file: StaticString = #filePath, line: UInt = #line) -> T? {
        switch result {
        case let .success(item):
            return item
        default:
            XCTFail("Unexpected state, expected success received \(result)", file: file, line: line)
        }
        return nil
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CharacterFeedLoader {
        let client = URLSessionHTTPClient()
        let sut = MarvelCharactersFeedLoader(client: client)

        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "Potential memory leak", file: file, line: line)
        }

        return sut
    }

    override class func tearDown() {
        super.tearDown()

        URLProtocolStub.stopIntercepting()
    }
}
