//
//  MarvelFeedProviderTests.swift
//  MarvelTests
//
//  Created by Hugo Alonso on 27/11/2020.
//

import XCTest
@testable import Marvel

import CharactersAPI
import Foundation
import UIKit

class MarvelFeedProvider {
    var charactersLoader: CharacterFeedLoader
    var prefetchImageHandler: (URL, String) -> Void
    var loadImageHandler: (URL, String, UIImageView) -> Void

    init(charactersLoader: CharacterFeedLoader,
         prefetchImageHandler: @escaping (URL, String) -> Void,
         loadImageHandler: @escaping  (URL, String, UIImageView) -> Void) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
    }
}


class MarvelFeedProviderTests: XCTestCase {

    struct FakeCharacterFeedLoader: CharacterFeedLoader {
        func character(id: Int, completion: @escaping SingleCharacterFeedLoaderResult) {

        }
        func characters(page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {

        }
        func search(by name: String, in page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {

        }
    }

    func testComposer_init() {
        let charactersLoader: CharacterFeedLoader = FakeCharacterFeedLoader()
        let prefetchImageHandler: (URL, String) -> Void  = { _, _ in }
        let loadImageHandler: (URL, String, UIImageView) -> Void = { _, _, _ in }

        _ = MarvelFeedProvider(charactersLoader: charactersLoader, prefetchImageHandler: prefetchImageHandler, loadImageHandler: loadImageHandler)
    }
}
