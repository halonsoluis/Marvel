import CharactersAPI
import Foundation
import XCTest

class URLSessionHTTPClientTests: XCTestCase {
    func test_load_onFailure_FailsWithError() {
        URLProtocolStub.startIntercepting()
        let expectedError = NSError(domain: "anyerror", code: 123, userInfo: nil)
        let sut = URLSessionHTTPClient()
        let url = URL(string: "www.url.com")!
        URLProtocolStub.stub(data: nil, response: nil, error: expectedError)

        let expect = expectation(description: "Waiting for expectation")

        sut.get(from: url) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(receivedError as NSError):
                XCTAssertEqual(expectedError.domain, receivedError.domain)
                XCTAssertEqual(expectedError.code, receivedError.code)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1)
        URLProtocolStub.stopIntercepting()
    }
}
