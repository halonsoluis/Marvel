//
//  MarvelFeedProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 27/11/2020.
//

import Foundation
import CharactersAPI
import UIKit

final class MarvelFeedProvider: FeedDataProvider {

    private var charactersLoader: CharacterFeedLoader
    private var prefetchImageHandler: ((url: URL,uniqueKey: String)) -> Void
    private var loadImageHandler: ((url: URL,uniqueKey: String), _ destinationView: UIImageView) -> Void
    private var router: (_ route: Route) -> Void

    private var nextPage = 0
    private var searchCriteria: String?

    var items: [BasicCharacterData] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }
    var onItemsChangeCallback: (() -> Void)?
    var workInProgress = false

    init(charactersLoader: CharacterFeedLoader,
         prefetchImageHandler: @escaping (ImageFormula) -> Void,
         loadImageHandler: @escaping  (ImageFormula, UIImageView) -> Void,
         router: @escaping  (Route) -> Void) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
        self.router = router
    }

    func perform(action: CharactersFeedUserAction) {
        switch action {
        case .loadFromStart:
            loadFromStart()
        case .loadMore:
            loadMore()
        case .openItem(let index):
            if index < items.count {
                openItem(at: items[index].id)
            }
        case .search(let name):
            if let search = name, search.count > 3 {
                searchCriteria = search
                loadFromStart()
            } else if name == "" {
                searchCriteria = nil
                loadFromStart()
            }
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

            DispatchQueue.main.async {
                self.loadImageHandler(item.imageFormula, imageField)
            }
        }
    }

    private func loadFromStart() {
        guard !workInProgress else { return }
        workInProgress = true

        nextPage = 0

        func completion(result: Result<[MarvelCharacter], Error>) {
            switch result {
            case .success(let characters):
                items.removeAll()
                items.append(contentsOf: characters.compactMap(BasicCharacterData.init))
            case .failure(let error):
                break //Display errors?
            }
            workInProgress = false
        }

        if let criteria = searchCriteria, criteria.count > 3 {
            charactersLoader.search(by: criteria, in: 0, completion: completion)
        } else {
            charactersLoader.characters(page: 0, completion: completion)
        }
    }

    private func loadMore() {
        guard !workInProgress else { return }
        workInProgress = true

        nextPage += 1

        func completion(result: Result<[MarvelCharacter], Error>) {
            switch result {
            case .success(let characters):
                items.append(contentsOf: characters.compactMap(BasicCharacterData.init))
            case .failure(let error):
                break //Display errors?
            }
            workInProgress = false
        }

        if let criteria = searchCriteria {
            charactersLoader.search(by: criteria, in: nextPage, completion: completion)
        } else {
            charactersLoader.characters(page: nextPage, completion: completion)
        }
    }

    private func prefetchImagesForNewItems(newItems: [BasicCharacterData]) {
        newItems.map{ $0.imageFormula }.forEach(prefetchImageHandler)
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

     func result(result: Result<[MarvelCharacter], Error>) -> [MarvelCharacter] {
        switch result {
        case .success(let items):
            if let item = items.first, let image = item.thumbnail, let modified = item.modified {
                prefetchImageHandler((image, modified))
            }
            return items
        case .failure(let error):
            return []
        }
    }
}
