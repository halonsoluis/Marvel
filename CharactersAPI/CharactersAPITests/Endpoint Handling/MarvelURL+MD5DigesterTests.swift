@testable import CharactersAPI
import XCTest

class MarvelURL_MD5DigesterTests: XCTestCase {
    func test_HashCreationWithSingleString() {
        XCTAssertEqual(MarvelURL.MD5Digester.createHash("1abcd1234"), "ffd275c5130566a2916217b101f26150")
    }

    func test_HashCreationWithMultipleString() {
        XCTAssertEqual(MarvelURL.MD5Digester.createHash("1ab", "cd1", "234"), "ffd275c5130566a2916217b101f26150")
    }

    func test_HashCreationWithEmptyLine() {
        XCTAssertNotNil(MarvelURL.MD5Digester.createHash(""))
    }
}
