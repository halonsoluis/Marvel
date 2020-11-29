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

class MarvelFeedProvider: FeedDataProvider {

    enum Action {
        case loadFromStart
        case loadMore
        case openItem(index: Int)
        case search(name: String?)
        case prepareForDisplay(indexes: [Int])
        case setHeroImage(index: Int, on: UIImageView)
    }

    private var charactersLoader: CharacterFeedLoader
    private var prefetchImageHandler: (_ url: URL, _ uniqueKey: String) -> Void
    private var loadImageHandler: (_ url: URL, _ uniqueKey: String, _ destinationView: UIImageView) -> Void
    private var router: (_ route: Route) -> Void

    private var nextPage = 0
    private var searchCriteria: String?

    var items: [BasicCharacterData] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }
    var onItemsChangeCallback: (() -> Void)?

    init(charactersLoader: CharacterFeedLoader,
         prefetchImageHandler: @escaping (URL, String) -> Void,
         loadImageHandler: @escaping  (URL, String, UIImageView) -> Void,
         router: @escaping  (Route) -> Void) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
        self.router = router
    }

    func perform(action: Action) {
        switch action {
        case .loadFromStart:
            loadFromStart()
        case .loadMore:
            loadMore()
        case .openItem(let index):
            if index < items.count, let itemId = items[index].id {
                openItem(at: itemId)
            }
        case .search(let name):
            searchCriteria = name
        case .prepareForDisplay(let indexes):
            prefetchImagesForNewItems(newItems: indexes.compactMap {
                guard items.count > $0 else {
                    return nil
                }
                return items[$0]
            })
        case .setHeroImage(let index, let imageField):
            guard index < items.count else { return }
            
            let item = items[index]

            if let image = item.thumbnail, let modified = item.modified {
                loadImageHandler(image, modified, imageField)
            }
        }
    }

    private func loadFromStart() {
        nextPage = 0

        func completion(result: Result<[MarvelCharacter], Error>) {
            switch result {
            case .success(let characters):
                items.removeAll()
                items.append(
                    contentsOf: characters.map {
                        BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified)
                    }
                )
            case .failure(let error):
                break //Display errors?
            }
        }

        if let criteria = searchCriteria, criteria.count > 3 {
            charactersLoader.search(by: criteria, in: 0, completion: completion)
        } else {
            charactersLoader.characters(page: 0, completion: completion)
        }
    }

    private func loadMore() {
        nextPage += 1

        func completion(result: Result<[MarvelCharacter], Error>) {
            switch result {
            case .success(let characters):
                items.append(
                    contentsOf: characters.map {
                        BasicCharacterData(id: $0.id, name: $0.name, thumbnail: $0.thumbnail, modified: $0.modified)
                    }
                )
            case .failure(let error):
                break //Display errors?
            }
        }

        if let criteria = searchCriteria {
            charactersLoader.search(by: criteria, in: nextPage, completion: completion)
        } else {
            charactersLoader.characters(page: nextPage, completion: completion)
        }
    }

    private func prefetchImagesForNewItems(newItems: [BasicCharacterData]) {
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
                    self?.router(.details(for: item))
                } else {
                    // What to do here?
                }
            case .failure(let error):
                break
            }
        }
    }

    private func openSearch() {
        nextPage = 0
        items.removeAll()
        router(.search)
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
