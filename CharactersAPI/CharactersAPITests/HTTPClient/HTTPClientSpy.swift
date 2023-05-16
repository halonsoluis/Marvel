import CharactersAPI
import Foundation

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    var returnedJSON: [String: Any]?
    var returnedError: Error?
    var returnedStatusCode: Int = 200

    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        requestedURL = url

        if let returnedError {
            completion(.failure(returnedError))
            return
        }

        if let returnedJSON {
            let data = try! JSONSerialization.data(withJSONObject: returnedJSON)
            completion(.success((data, HTTPURLResponse(url: url, statusCode: returnedStatusCode, httpVersion: nil, headerFields: nil)!)))
        }
    }
}
