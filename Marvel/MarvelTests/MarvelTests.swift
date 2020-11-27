//
//  MarvelTests.swift
//  MarvelTests
//
//  Created by Hugo Alonso on 24/11/2020.
//

import XCTest
@testable import Marvel

import UIKit
import CharactersAPI
import ImageLoader

class MainComposer {

    func main() {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let charactersLoader = MarvelCharactersFeedLoader(client: client)

        let prefetchImageHandler = { (url: URL, modifiedKey: String) in
            ImageLoader(url: url, uniqueKey: modifiedKey).image.prefetch(completion: { _ in })
        }

        let loadImageHandler = { (url: URL, modifiedKey: String, imageView: UIImageView) in
            ImageLoader(url: url, uniqueKey: modifiedKey).image.render(on: imageView, completion: { _ in })
        }

        _ = MarvelFeedProvider(charactersLoader: charactersLoader, prefetchImageHandler: prefetchImageHandler, loadImageHandler: loadImageHandler)
    }
}


class MarvelTests: XCTestCase {
    func test_MainComposerIntegration() {
        let sut = MainComposer()
        sut.main()
    }
}
