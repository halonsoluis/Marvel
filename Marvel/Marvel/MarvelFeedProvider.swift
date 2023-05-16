import CharactersAPI
import Foundation
import ImageLoader
import UIKit

final class MarvelFeedProvider: FeedDataProvider {
    private let charactersLoader: CharacterFeedLoader
    private let prefetchImageHandler: (ImageFormula) -> Cancellable?
    private let loadImageHandler: ((url: URL, uniqueKey: String), _ destinationView: UIImageView) -> Cancellable?
    private let router: (_ route: Route) -> Void

    private var nextPage = 0
    private var searchCriteria: String?

    var items: [BasicCharacterData] = [] {
        didSet {
            onItemsChangeCallback?()
        }
    }

    var onItemsChangeCallback: (() -> Void)?
    var workInProgress = false

    init(
        charactersLoader: CharacterFeedLoader,
        prefetchImageHandler: @escaping (ImageFormula) -> Cancellable?,
        loadImageHandler: @escaping (ImageFormula, UIImageView) -> Cancellable?,
        router: @escaping (Route) -> Void
    ) {
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
        case let .openItem(index):
            if index < items.count {
                openItem(at: items[index].id)
            }
        case let .search(name):
            if let search = name, search.count > 3 {
                searchCriteria = search
                loadFromStart()
            } else if name == "" {
                searchCriteria = nil
                loadFromStart()
            }
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

    private func loadFromStart() {
        guard !workInProgress else {
            return
        }
        workInProgress = true

        nextPage = 0

        func completion(result: Result<[MarvelCharacter], Error>) {
            switch result {
            case let .success(characters):
                items.removeAll()
                items.append(contentsOf: characters.compactMap(BasicCharacterData.init))
            case .failure:
                break // Display errors?
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
        guard !workInProgress else {
            return
        }
        workInProgress = true

        nextPage += 1

        func completion(result: Result<[MarvelCharacter], Error>) {
            switch result {
            case let .success(characters):
                items.append(contentsOf: characters.compactMap(BasicCharacterData.init))
            case .failure:
                break // Display errors?
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
        newItems
            .map(\.imageFormula)
            .forEach { _ = _ = prefetchImageHandler($0) }
    }

    private func openItem(at index: Int) {
        charactersLoader.character(id: index) { [weak self] result in
            switch result {
            case let .success(item):
                if let item {
                    self?.router(.details(for: item))
                } else {
                    // Wha_ere?
                }
            case .failure:
                break
            }
        }
    }

    func result(result: Result<[MarvelCharacter], Error>) -> [MarvelCharacter] {
        switch result {
        case let .success(items):
            if let item = items.first, let image = item.thumbnail, let modified = item.modified {
                _ = prefetchImageHandler((image, modified))
            }
            return items
        case .failure:
            return []
        }
    }
}
