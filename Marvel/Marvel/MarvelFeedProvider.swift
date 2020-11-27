//
//  MarvelFeedProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 27/11/2020.
//

import Foundation
import CharactersAPI
import Foundation
import UIKit

protocol FeedDataProvider {
    var items: [MarvelCharacter] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: MarvelFeedProvider.Action)
}

class MarvelFeedProvider: FeedDataProvider {

    enum Action {
        case loadFromStart
        case loadMore
        case openItem(id: Int)
        case openSearch
    }

    private var charactersLoader: CharacterFeedLoader
    private var prefetchImageHandler: (URL, String) -> Void
    private var loadImageHandler: (URL, String, UIImageView) -> Void

    private var nextPage = 0

    var items: [MarvelCharacter] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }
    var onItemsChangeCallback: (() -> Void)?

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
