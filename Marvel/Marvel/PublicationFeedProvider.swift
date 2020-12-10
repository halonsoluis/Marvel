//
//  PublicationFeedProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 10/12/2020.
//

import Foundation
import CharactersAPI
import UIKit

class PublicationFeedProvider: PublicationFeedDataProvider {

    private var charactersLoader: CharacterFeedLoader
    private var prefetchImageHandler: (_ url: URL, _ uniqueKey: String) -> Void
    private var loadImageHandler: (_ url: URL, _ uniqueKey: String, _ destinationView: UIImageView) -> Void
    private var nextPage = 0

    var items: [MarvelPublication] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }
    var onItemsChangeCallback: (() -> Void)?
    var workInProgress = false

    init(charactersLoader: CharacterFeedLoader,
         prefetchImageHandler: @escaping (URL, String) -> Void,
         loadImageHandler: @escaping  (URL, String, UIImageView) -> Void) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
    }

    func perform(action: CharactersFeedUserAction) {
        switch action {
        case .loadFromStart:
            loadFromStart()
        case .loadMore:
            loadMore()
        case .openItem(let index):
            if index < items.count {
                openItem(at: items[index].id!)
            }
        case .search:
            break
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
                self.loadImageHandler(item.thumbnail!, item.modified!, imageField)
            }
        }
    }

    private func loadFromStart() {
        guard !workInProgress else { return }
        workInProgress = true

        nextPage = 0

        func completion(result: Result<[MarvelPublication], Error>) {
            switch result {
            case .success(let characters):
                items.removeAll()
                items.append(
                    contentsOf: characters
                )
            case .failure(let error):
                break //Display errors?
            }
            workInProgress = false
        }

        charactersLoader.publication(
            characterId: 1011334,
            type: .comics,
            page: 0,
            completion: completion
        )
    }

    private func loadMore() {
        guard !workInProgress else { return }
        workInProgress = true

        nextPage += 1

        func completion(result: Result<[MarvelPublication], Error>) {
            switch result {
            case .success(let characters):
                items.append(
                    contentsOf: characters
                )
            case .failure(let error):
                break //Display errors?
            }
            workInProgress = false
        }

        charactersLoader.publication(
            characterId: 1011334,
            type: .comics,
            page: nextPage,
            completion: completion
        )

    }

    private func prefetchImagesForNewItems(newItems: [MarvelPublication]) {
        newItems.forEach { item in
            prefetchImageHandler(item.thumbnail!, item.modified!)
        }
    }

    private func openItem(at index: Int) {

    }

     func result(result: Result<[MarvelPublication], Error>) -> [MarvelPublication] {
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
