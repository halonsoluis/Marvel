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

class MarvelFeedProviderTests: XCTestCase {

    class CharacterFeedLoaderSpy: CharacterFeedLoader {
        var characterCallCount = 0
        var characterCalledWith: (id: Int, completion: SingleCharacterFeedLoaderResult)?
        func character(id: Int, completion: @escaping SingleCharacterFeedLoaderResult) {
            characterCallCount += 1
            characterCalledWith = (id: id, completion: completion)
        }

        var charactersCallCount = 0
        var charactersCalledWith: (page: Int, completion: MultipleCharacterFeedLoaderResult)?
        func characters(page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {
            charactersCallCount += 1
            charactersCalledWith = (page: page, completion: completion)
        }

        var searchCallCount = 0
        var searchCalledWith: (name: String, page: Int, completion: MultipleCharacterFeedLoaderResult)?
        func search(by name: String, in page: Int, completion: @escaping MultipleCharacterFeedLoaderResult) {
            searchCallCount += 1
            searchCalledWith = (name: name, page: page, completion: completion)
        }
    }

    func createSUT() -> (sut: MarvelFeedProvider, charactersLoader: CharacterFeedLoaderSpy) {
        let charactersLoader = CharacterFeedLoaderSpy()
        let prefetchImageHandler: (URL, String) -> Void  = { _, _ in }
        let loadImageHandler: (URL, String, UIImageView) -> Void = { _, _, _ in }

        let sut = MarvelFeedProvider(charactersLoader: charactersLoader, prefetchImageHandler: prefetchImageHandler, loadImageHandler: loadImageHandler)

        return (sut, charactersLoader)
    }

    func testPerform_loadFromStart() {
        let (sut, charactersLoader) = createSUT()

        sut.perform(action: .loadFromStart)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 0)

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 1)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)

        sut.perform(action: .loadFromStart)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 0)

        XCTAssertEqual(sut.items, [])

        let item = MarvelCharacter(id: 1, name: "name", description: "description", modified: "modified", thumbnail: nil)
        charactersLoader.charactersCalledWith?.completion(.success([item]))

        XCTAssertEqual(sut.items, [item])

        sut.perform(action: .loadFromStart)
        XCTAssertEqual(sut.items, [])

    }

    func testPerform_loadMore() {
        let (sut, charactersLoader) = createSUT()

        sut.perform(action: .loadMore)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 1)

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 1)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)

        sut.perform(action: .loadMore)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 2)

        XCTAssertEqual(sut.items, [])

        let item = MarvelCharacter(id: 1, name: "name", description: "description", modified: "modified", thumbnail: nil)
        charactersLoader.charactersCalledWith?.completion(.success([item]))

        XCTAssertEqual(sut.items, [item])

        sut.perform(action: .loadMore)
        XCTAssertEqual(sut.items, [item])
    }

    func testPerform_openItem() {
        let (sut, charactersLoader) = createSUT()

        sut.perform(action: .openItem(id: 1))

        XCTAssertEqual(charactersLoader.characterCallCount, 1)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)

        XCTAssertEqual(charactersLoader.characterCalledWith?.id, 1)

        XCTAssertEqual(sut.items, [])

        let item = MarvelCharacter(id: 1, name: "name", description: "description", modified: "modified", thumbnail: nil)
        charactersLoader.characterCalledWith?.completion(.success(item))

        XCTAssertEqual(sut.items, [])
    }

    func testPerform_openSearch() {
        let (sut, charactersLoader) = createSUT()

        sut.perform(action: .openSearch)

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)

        XCTAssertEqual(sut.items, [])
    }
}
