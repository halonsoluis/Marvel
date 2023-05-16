import Foundation

class URLProtocolStub: URLProtocol {
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

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let data = Self.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = Self.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = Self.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
