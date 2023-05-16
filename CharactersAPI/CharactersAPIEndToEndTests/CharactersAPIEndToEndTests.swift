@testable import CharactersAPI
import XCTest

class CharactersAPIEndToEndTests: XCTestCase {
    func test_load_DataFromNetwork() {
        let (sut, marvelURL) = createSUT()
        let url = marvelURL.url(route: .characters)!

        expectToResolve(url: url, sut: sut, with: 200)
    }

    func test_load_DataFromNetworkSingleCharacterEndpoint() {
        let (sut, marvelURL) = createSUT()
        let url = marvelURL.url(route: .character(id: 1_011_334))!

        expectToResolve(url: url, sut: sut, with: 200)
    }

    func test_load_DataFromNetworkSingleCharacterEndpoint_FailsWith404IfNotFound() {
        let (sut, marvelURL) = createSUT()
        let url = marvelURL.url(route: .character(id: -1))!

        expectToResolve(url: url, sut: sut, with: 404)
    }

    func test_load_DataFromNetworkFilteringCharacterEndpoint() {
        let (sut, marvelURL) = createSUT()
        let url = marvelURL.url(route: .characters, nameStartingWith: "a")!

        expectToResolve(url: url, sut: sut, with: 200)
    }

    func expectToResolve(url: URL, sut: HTTPClient, with statusCode: Int, file: StaticString = #filePath, line: UInt = #line) {
        let expect = expectation(description: "Waiting for \(url) to resolve")

        sut.get(from: url) { result in
            switch result {
            case let .success((_, response)):
                XCTAssertEqual(response.statusCode, statusCode, "Wrong status Code received", file: file, line: line)
            case let .failure(receivedError as NSError):
                XCTFail("Unexpected Error Received \(receivedError.description)", file: file, line: line)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func createSUT(_ urlString: String = "https://gateway.marvel.com:443/v1/public", file: StaticString = #filePath, line: UInt = #line) -> (HTTPClient, MarvelURL) {
        let sut = URLSessionHTTPClient()
        let url = MarvelURL(URL(string: urlString)!, config: .shared, hashResolver: MarvelURL.MD5Digester.createHash, timeProvider: Date.init)

        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "Potential memory leak", file: file, line: line)
        }

        return (sut, url)
    }
}
