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

    func testPerform_loadFromStart_leadsToASingleAPICall() {
        let (sut, charactersLoader,_) = createSUT()

        sut.perform(action: .loadFromStart)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 0)

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 1)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)
    }

    func testPerform_loadFromStart_AlwaysLoadsTheFirstPage() {
        let (sut, charactersLoader,_) = createSUT()

        sut.perform(action: .loadFromStart)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 0)

        sut.perform(action: .loadFromStart)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 0)
    }

    func testPerform_loadFromStart_returnsLoadedItemsWhenReady() {
        let (sut, charactersLoader, items) = createSUT(itemCount: 2)

        sut.perform(action: .loadFromStart)
        charactersLoader.charactersCalledWith?.completion(
            .success(items)
        )
        XCTAssertEqual(sut.items, items.compactMap { BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified) })
    }

    func testPerform_loadFromStart_alwaysCleanPreviousItemsWhenCalled() {
        let (sut, charactersLoader, items) = createSUT(itemCount: 2)

        sut.perform(action: .loadFromStart)
        charactersLoader.charactersCalledWith?.completion(
            .success(items)
        )
        XCTAssertEqual(sut.items.count, 2)

        sut.perform(action: .loadFromStart)
        let newItems = createItems(amount: 10)
        charactersLoader.charactersCalledWith?.completion(.success(newItems))
        XCTAssertEqual(sut.items, newItems.compactMap { BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified) })
    }

    func testPerform_loadMore_leadsToASingleAPICall() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .loadMore)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 1)

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 1)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)
    }

    func testPerform_loadMore_RequestNextPage() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .loadMore)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 1)

        sut.perform(action: .loadMore)
        XCTAssertEqual(charactersLoader.charactersCalledWith?.page, 2)
    }

    func testPerform_loadMore_returnsLoadedItemsWhenReady() {
        let (sut, charactersLoader, items) = createSUT(itemCount: 2)

        sut.perform(action: .loadMore)
        charactersLoader.charactersCalledWith?.completion(
            .success(items)
        )
        XCTAssertEqual(sut.items, items.compactMap { BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified) })
    }

    func testPerform_loadMore_doNotCleanPreviousItemsWhenCalled() {
        let (sut, charactersLoader, items) = createSUT(itemCount: 2)

        sut.perform(action: .loadMore)
        charactersLoader.charactersCalledWith?.completion(
            .success(items)
        )
        XCTAssertEqual(sut.items.count, 2)

        sut.perform(action: .loadMore)
        charactersLoader.charactersCalledWith?.completion(.success(createItems(amount: 10)))

        XCTAssertEqual(sut.items.count, 12)
    }

    func testPerform_openItemWithNoItems_PerformNoCalls() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .openItem(index: 0))

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)
    }

    func testPerform_openItemWithItems_PerformCallsForItemInIndex() {
        let (sut, charactersLoader, items) = createSUT(itemCount: 2)
        sut.items = items.compactMap { BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified) }

        sut.perform(action: .openItem(index: 0))

        XCTAssertEqual(charactersLoader.characterCallCount, 1)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)

        XCTAssertEqual(charactersLoader.characterCalledWith?.id, items[0].id)
    }


    func testPerform_searchWithInvalidText_performNoAPICalls() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .search(name: "ab"))

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)
    }

    func testPerform_searchWithEmptyText_performsCharactersAPICalls() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .search(name: ""))

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 1)
        XCTAssertEqual(charactersLoader.searchCallCount, 0)
    }

    func testPerform_searchWithValidText_performsSearchPICalls() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .search(name: "sdfsdf"))

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 1)
    }

    func testPerform_searchWithValidText_performsSearchAPICalls() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .search(name: "sdfsdf"))

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 1)

        XCTAssertEqual(charactersLoader.searchCalledWith?.name, "sdfsdf")
        XCTAssertEqual(charactersLoader.searchCalledWith?.page, 0)
    }

    func testPerform_searchWithValidText_LoadMore_performsSearchAPICalls() {
        let (sut, charactersLoader, _) = createSUT()

        sut.perform(action: .search(name: "sdfsdf"))

        XCTAssertEqual(charactersLoader.characterCallCount, 0)
        XCTAssertEqual(charactersLoader.charactersCallCount, 0)
        XCTAssertEqual(charactersLoader.searchCallCount, 1)

        XCTAssertEqual(charactersLoader.searchCalledWith?.name, "sdfsdf")
        XCTAssertEqual(charactersLoader.searchCalledWith?.page, 0)
    }


    func testPerform_openItemWithItems_triggerDetailsRoute() {
        var route: Route!
        let (sut, charactersLoader, items) = createSUT(itemCount: 1, router: { route = $0 })
        sut.items = items.compactMap { BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified) }

        sut.perform(action: .openItem(index: 0))

        charactersLoader.characterCalledWith?.completion(.success(items.first))

        XCTAssertEqual(route, Route.details(for: items[0]))
    }

}

// MARK - Helpers
extension MarvelFeedProviderTests {
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

    func createSUT(
        itemCount: Int = 0,
        charactersLoader: CharacterFeedLoaderSpy = CharacterFeedLoaderSpy(),
        prefetchImageHandler: @escaping (URL, String) -> Void  = { _, _ in },
        loadImageHandler: @escaping (URL, String, UIImageView) -> Void = { _, _, _ in },
        router: @escaping (Route) -> Void = { _ in }
    ) -> (sut: MarvelFeedProvider, charactersLoader: CharacterFeedLoaderSpy, items: [MarvelCharacter]) {
        let sut = MarvelFeedProvider(charactersLoader: charactersLoader, prefetchImageHandler: prefetchImageHandler, loadImageHandler: loadImageHandler, router: router)

        return (sut, charactersLoader, createItems(amount: itemCount))
    }

    private func createItems(amount: Int) -> [MarvelCharacter] {
        let itemBuilder = { MarvelCharacter(id: Int.random(in: 1...100), name: "name", description: "description", modified: "modified", thumbnail: URL(string: "https://any-url.com")!) }
        return Array(repeating: itemBuilder(), count: amount)
    }
}
