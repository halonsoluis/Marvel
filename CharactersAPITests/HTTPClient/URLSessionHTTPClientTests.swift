//
//  URLSessionHTTPClientTests.swift
//  CharactersAPITests
//
//  Created by Hugo Alonso on 16/11/2020.
//

import XCTest
import Foundation
import CharactersAPI

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

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?

    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        Self.stub = Stub(data: data, response: response, error: error)
    }

    static func startIntercepting() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopIntercepting() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = Self.stub else {
            return
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}
