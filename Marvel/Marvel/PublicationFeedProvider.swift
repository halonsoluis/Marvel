import CharactersAPI
import Foundation
import ImageLoader
import UIKit

final class PublicationFeedProvider: PublicationFeedDataProvider {
    private let charactersLoader: CharacterFeedLoader
    private let prefetchImageHandler: (ImageFormula) -> Cancellable?
    private let loadImageHandler: (ImageFormula, _ destinationView: UIImageView) -> Cancellable?
    private var nextPage = 0

    var items: [BasicPublicationData] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }

    var onItemsChangeCallback: (() -> Void)?
    var workInProgress = false

    init(
        charactersLoader: CharacterFeedLoader,
        prefetchImageHandler: @escaping (ImageFormula) -> Cancellable?,
        loadImageHandler: @escaping (ImageFormula, UIImageView) -> Cancellable?
    ) {
        self.charactersLoader = charactersLoader
        self.prefetchImageHandler = prefetchImageHandler
        self.loadImageHandler = loadImageHandler
    }

    func perform(action: CharactersDetailsUserAction) {
        switch action {
        case let .loadFromStart(characterId, type):
            guard let type = MarvelPublication.Kind(rawValue: type) else {
                return
            }

            loadFromStart(characterId: characterId, type: type)
        case let .loadMore(characterId, type):
            guard let type = MarvelPublication.Kind(rawValue: type) else {
                return
            }

            loadMore(characterId: characterId, type: type)
        case let .prepareForDisplay(indexes):
            prefetchImagesForNewItems(newItems: indexes.compactMap {
                guard items.count > $0 else {
                    return nil
                }
                return items[$0]
            })
        case let .setHeroImage(index, imageField):
            guard index < items.count else {
                return
            }

            let item = items[index]

            DispatchQueue.main.async {
                _ = self.loadImageHandler(item.imageFormula, imageField)
            }
        }
    }

    private func loadFromStart(characterId: Int, type: MarvelPublication.Kind) {
        guard !workInProgress else {
            return
        }
        workInProgress = true

        nextPage = 0

        func completion(result: Result<[MarvelPublication], Error>) {
            switch result {
            case let .success(characters):
                items.removeAll()
                items.append(contentsOf: characters.compactMap(BasicPublicationData.init))
            case .failure:
                break // Display errors?
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
        guard !workInProgress else {
            return
        }
        workInProgress = true

        nextPage += 1

        func completion(result: Result<[MarvelPublication], Error>) {
            switch result {
            case let .success(characters):
                let insertedIds = items.map(\.id)
                let newItems = characters.compactMap(BasicPublicationData.init)

                items.append(contentsOf: newItems.filter { !insertedIds.contains($0.id) })
            case .failure:
                break // Display errors?
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

    private func prefetchImagesForNewItems(newItems: [BasicPublicationData]) {
        newItems
            .map(\.imageFormula)
            .forEach { _ = prefetchImageHandler($0) }
    }

    private func openItem(at _: Int) {
        // Not on scope so far
    }

    func result(result: Result<[MarvelPublication], Error>) -> [MarvelPublication] {
        switch result {
        case let .success(items):
            if let item = items.first, let url = item.thumbnail, let modified = item.modified {
                _ = prefetchImageHandler((url, modified))
            }
            return items
        case .failure:
            return []
        }
    }
}
