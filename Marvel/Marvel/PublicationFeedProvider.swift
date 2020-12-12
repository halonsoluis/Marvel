//
//  PublicationFeedProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 10/12/2020.
//

import Foundation
import CharactersAPI
import UIKit

final class PublicationFeedProvider: PublicationFeedDataProvider {

    private var charactersLoader: CharacterFeedLoader
    private var prefetchImageHandler: (ImageFormula) -> Void
    private var loadImageHandler: (ImageFormula, _ destinationView: UIImageView) -> Void
    private var nextPage = 0

    var items: [MarvelPublication] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }
    var onItemsChangeCallback: (() -> Void)?
    var workInProgress = false

    init(charactersLoader: CharacterFeedLoader,
         prefetchImageHandler: @escaping (ImageFormula) -> Void,
         loadImageHandler: @escaping  (ImageFormula, UIImageView) -> Void) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
    }

    func perform(action: CharactersDetailsUserAction) {
        switch action {
        case let .loadFromStart(characterId, type):
            loadFromStart(characterId: characterId, type: type)
        case let .loadMore(characterId, type):
            loadMore(characterId: characterId, type: type)
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

            if let thumbnail = item.thumbnail, let modified = item.modified {
                DispatchQueue.main.async {
                    self.loadImageHandler((thumbnail, modified), imageField)
                }
            }
        }
    }

    private func loadFromStart(characterId: Int, type: MarvelPublication.Kind) {
        guard !workInProgress else { return }
        workInProgress = true

        nextPage = 0

        func completion(result: Result<[MarvelPublication], Error>) {
            switch result {
            case .success(let characters):
                items.removeAll()
                items.append(
                    contentsOf: characters.filter { $0.thumbnail != nil }
                )
            case .failure(let error):
                break //Display errors?
            }
            workInProgress = false
        }

        charactersLoader.publication(
            characterId: characterId,
            type: type,
            page: 0,
            completion: completion
        )
    }

    private func loadMore(characterId: Int, type: MarvelPublication.Kind) {
        guard !workInProgress else { return }
        workInProgress = true

        nextPage += 1

        func completion(result: Result<[MarvelPublication], Error>) {
            switch result {
            case .success(let characters):
                items.append(
                    contentsOf: characters.filter { $0.thumbnail != nil }
                )
            case .failure(let error):
                break //Display errors?
            }
            workInProgress = false
        }

        charactersLoader.publication(
            characterId: characterId,
            type: type,
            page: nextPage,
            completion: completion
        )
    }

    private func prefetchImagesForNewItems(newItems: [MarvelPublication]) {
        newItems.forEach { item in
            prefetchImageHandler((item.thumbnail!, item.modified!))
        }
    }

    private func openItem(at index: Int) {

    }

     func result(result: Result<[MarvelPublication], Error>) -> [MarvelPublication] {
        switch result {
        case .success(let items):
            if let item = items.first, let url = item.thumbnail, let modified = item.modified {
                prefetchImageHandler((url, modified))
            }
            return items
        case .failure(let error):
            return []
        }
    }

}
