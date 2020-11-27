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

    enum Action {
        case loadFromStart
        case loadMore
        case openItem(id: Int)
        case openSearch
    }

    private var charactersLoader: CharacterFeedLoader
    private var prefetchImageHandler: (URL, String) -> Void
    private var loadImageHandler: (URL, String, UIImageView) -> Void

    var items: [MarvelCharacter] = []
    private var nextPage = 0

    init(charactersLoader: CharacterFeedLoader,
         prefetchImageHandler: @escaping (URL, String) -> Void,
         loadImageHandler: @escaping  (URL, String, UIImageView) -> Void) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
    }

    func perform(action: Action) {
        switch action {
        case .loadFromStart:
            loadFromStart()
        case .loadMore:
            loadMore()
        case .openItem(let id):
            openItem(at: id)
        case .openSearch:
            openSearch()
        }
    }

    private func loadFromStart() {
        nextPage = 0
        items.removeAll()
        charactersLoader.characters(page: 0, completion: handleCharactersResult)
    }

    private func loadMore() {
        nextPage += 1
        charactersLoader.characters(page: nextPage, completion: handleCharactersResult)
    }

    private func handleCharactersResult(result: Result<[MarvelCharacter], Error>) {
        switch result {
        case .success(let characters):
            items.append(contentsOf: characters)
            prefetchImagesForNewItems(newItems: items)
        case .failure(let error):
            break //Display errors?
        }
    }

    private func prefetchImagesForNewItems(newItems: [MarvelCharacter]) {
        newItems.forEach { item in
            if let image = item.thumbnail, let modified = item.modified {
                prefetchImageHandler(image, modified)
            }
        }
    }

    private func openItem(at index: Int) {
        charactersLoader.character(id: index) { [weak self] result in
            switch result {
            case let .success(item):
                if let item = item {
                    self?.displayCharacterDetails(item: item)
                } else {
                    // What to do here?
                }
            case .failure(let error):
                break
            }
        }
    }

    private func displayCharacterDetails(item: MarvelCharacter) {

    }

    private func openSearch() {
        nextPage = 0
        items.removeAll()
    }

     func result(result: Result<[MarvelCharacter], Error>) -> [MarvelCharacter] {
        switch result {
        case .success(let items):
            if let item = items.first, let image = item.thumbnail, let modified = item.modified {
                prefetchImageHandler(image, modified)
            }
            return items
        case .failure(let error):
            return []
        }
    }
}


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
    }

    func testPerform_openItem() {
        let (sut, charactersLoader) = createSUT()

        sut.perform(action: .openItem(id: 1))

        XCTAssertEqual(charactersLoader.characterCallCount, 1)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)

        XCTAssertEqual(charactersLoader.characterCalledWith?.id, 1)

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
