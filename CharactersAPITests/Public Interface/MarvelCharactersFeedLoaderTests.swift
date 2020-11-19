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
        var receivedResult: Result<[MarvelCharacter], Error>!
        sut.characters(page: 0) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)

        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertEqual(items.count, 10)
    }

    func test_searchWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()
        stubHTTPResponseAndData(itemAmount: 10, statusCode: 200)

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<[MarvelCharacter], Error>!
        sut.search(by: "", in : 0) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)

        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertEqual(items.count, 10)
    }

    func test_singleCharacterWithValidResponse_producesAMarvelItem() {
        let sut = makeSUT()
        stubHTTPResponseAndData(itemAmount: 1, statusCode: 200)

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<MarvelCharacter?, Error>!
        sut.character(id: 0) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)

        let item = extractResultDataFromCall(result: receivedResult)!
        let jsonItem = makeValidJSONResponse(amountOfItems: 1, statusCode: 200).item

        XCTAssertEqual(item?.name, jsonItem["name"] as? String)
        XCTAssertEqual(item?.description, jsonItem["description"] as? String)
        XCTAssertEqual(item?.id, jsonItem["id"] as? Int)
        XCTAssertEqual(item?.modified, jsonItem["modified"] as? String)
    }

    func test_singleCharacterWithUnknownIdAndValidResponse_doesNotProduceAMarvelItem() {
        let sut = makeSUT()
        stubHTTPResponseAndData(itemAmount: 0, statusCode: 404)

        let expect = expectation(description: "A request for data to the network was issued")
        var receivedResult: Result<MarvelCharacter?, Error>!
        sut.character(id: 0) {
            receivedResult = $0
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)

        switch receivedResult {
        case .failure:
            break;
        default:
            XCTFail("This is expected to receive an error as the id is not valid")
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
