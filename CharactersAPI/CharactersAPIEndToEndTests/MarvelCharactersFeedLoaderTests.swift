import CharactersAPI
import XCTest

// Integration test to verify end2end system work as expected
class MarvelCharactersFeedLoaderTests: XCTestCase {
    func test_charactersCallWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()

        let receivedResult = performCharactersRequest(page: 0, using: sut, timeout: 5.0)
        let items = extractResultDataFromCall(result: receivedResult)!

        XCTAssertGreaterThan(items.count, 1, "Items Received")
    }

    func test_publicationCallWithValidResponse_producesMarvelEvents() {
        let receivedResult = performPublicationRequest(characterId: 1_011_334, type: .events, page: 0, using: makeSUT(), timeout: 5.0)
        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertGreaterThanOrEqual(items.count, 1)
    }

    func test_publicationCallWithValidResponse_produceMarvelComics() {
        let receivedResult = performPublicationRequest(characterId: 1_011_334, type: .comics, page: 0, using: makeSUT(), timeout: 5.0)
        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertGreaterThanOrEqual(items.count, 12)
    }

    func test_publicationCallWithValidResponse_producesMarvelSeries() {
        let receivedResult = performPublicationRequest(characterId: 1_017_100, type: .series, page: 0, using: makeSUT(), timeout: 5.0)
        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertGreaterThanOrEqual(items.count, 2)
    }

    func test_publicationCallWithValidResponse_producesMarvelStories() {
        let receivedResult = performPublicationRequest(characterId: 1_017_100, type: .stories, page: 0, using: makeSUT(), timeout: 5.0)
        let items = extractResultDataFromCall(result: receivedResult)!
        XCTAssertGreaterThanOrEqual(items.count, 6)
    }

    func test_searchWithValidResponse_producesMarvelItems() {
        let sut = makeSUT()

        let receivedResult = performSearchRequest(name: "a", page: 0, using: sut, timeout: 5.0)
        let items = extractResultDataFromCall(result: receivedResult)!

        XCTAssertGreaterThan(items.count, 1, "Items Received")
    }

    func test_singleCharacterWithValidResponse_producesAMarvelItem() {
        let sut = makeSUT()

        let receivedResult = performCharacterRequest(id: 1_011_334, using: sut, timeout: 5.0)
        let item = extractResultDataFromCall(result: receivedResult)!

        XCTAssertEqual(item?.name, "3-D Man")
    }

    func test_singleCharacterWithUnknownIdAndValidResponse_doesNotProduceAMarvelItem() {
        let sut = makeSUT()
        let receivedResult = performCharacterRequest(id: -1, using: sut, timeout: 5.0)

        switch receivedResult {
        case let .success(item):
            XCTAssertNil(item)
        default:
            XCTFail("This is expected to receive a nil item as a response to a not found id")
        }
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

        addTeardownBlock { [weak sut, weak client] in
            XCTAssertNil(sut, "Potential memory leak", file: file, line: line)
            XCTAssertNil(client, "Potential memory leak", file: file, line: line)
        }
        return sut
    }
}
