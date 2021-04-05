//
//  MainComposer.swift
//  Marvel
//
//  Created by Hugo Alonso on 27/11/2020.
//

import Foundation
import UIKit
import CharactersAPI
import ImageLoader

typealias ImageFormula = (url: URL, uniqueKey: String)
typealias Router = (_ route: Route) -> Void
typealias PrefetchImageHandler = (ImageFormula) -> Void
typealias LoadImageHandler = (ImageFormula, _ destinationView: UIImageView) -> Void

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

class MainComposer {
    private let baseView: UIWindow

    private let client = URLSessionHTTPClient(session: URLSession.shared)
    private lazy var charactersLoader = MarvelCharactersFeedLoader(client: client)

    private lazy var characterFeedDataProvider = MainQueueDispatchDecoratorFeedDataProvider(itemProvider)

    private func publicationsFeedDataProvider() -> PublicationFeedDataProvider { MainQueueDispatchDecoratorPublicationFeedDataProvider(publicationsProvider)
    }

    private var mainView: MainSplitView?
    private var characterDetails: CharacterDetailsViewController?

    init(baseView: UIWindow) {
        self.baseView = baseView
    }

    func start() {
        let feedViewVC = FeedViewController(
            feedDataProvider: characterFeedDataProvider
        )
        let characterDetailsVC = CharacterDetailsViewController(
            loadImageHandler: loadImageHandlerWithCompletion,
            feedDataProvider: publicationsFeedDataProvider
        )
        let mainView = MainSplitView(mainViewVC: feedViewVC, detailVC: characterDetailsVC)

        mainView.injectAsRoot(in: baseView)

        self.mainView = mainView
        self.characterDetails = characterDetailsVC
    }

    private lazy var itemProvider: FeedDataProvider = {
        func routerIntercept(route: Route) {
            router(route: route, using: baseView)
        }

        return MarvelFeedProvider(
            charactersLoader: charactersLoader,
            prefetchImageHandler: prefetchImageHandler,
            loadImageHandler: loadImageHandler,
            router: routerIntercept
        )
    }()

    private var publicationsProvider: PublicationFeedDataProvider {
        return PublicationFeedProvider(
            charactersLoader: charactersLoader,
            prefetchImageHandler: prefetchImageHandler,
            loadImageHandler: loadImageHandler
        )
    }
}

// MARK - Navigation
extension MainComposer {

    private func router(route: Route, using baseWindow: UIWindow ) {
        switch route {
        case .details(for: let item):
            guard let character = BasicCharacterData(character: item) else { return }

            DispatchQueue.main.async {
                self.createSectionsForCharacter(character: character)
            }
        }
    }

    private func createSectionsForCharacter(character: BasicCharacterData) {
        let sectionsForCharacter = MarvelPublication.Kind.allCases
            .map { (character.id, $0) }
            .compactMap(createSection)

        renderCharacter(item: character, sections: sectionsForCharacter)
    }

    private func createSection(characterId: Int, publicationKind: MarvelPublication.Kind) -> PublicationCollection {
        PublicationCollection(
            characterId: characterId,
            section: publicationKind.rawValue,
            loadImageHandler: self.loadImageHandlerWithCompletion,
            feedDataProvider: publicationsFeedDataProvider()
        )
    }

    private func renderCharacter(item: BasicCharacterData, sections: [PublicationCollection]) {
        characterDetails?.drawCharacter(item: item, sections: sections)
        mainView?.forceShowDetailView()
    }
}

// MARK - Image Handling
extension MainComposer {
    private func loadImageHandler(imageFormula: ImageFormula, imageView: UIImageView) {
        loadImageHandlerWithCompletion(
            imageFormula: imageFormula,
            imageView: imageView,
            completion: { _ in }
        )
    }

    private func loadImageHandlerWithCompletion(imageFormula: (url: URL, uniqueKey: String), imageView: UIImageView, completion: @escaping (Error?)->Void) {
        createImageLoader(
            url: imageFormula.url,
            modifiedKey: imageFormula.uniqueKey
        ).render(on: imageView, completion: completion)
    }

    private func prefetchImageHandler(url: URL, modifiedKey: String) {
        createImageLoader(url: url, modifiedKey: modifiedKey)
            .prefetch(completion: { _ in })
    }

    private func createImageLoader(url: URL, modifiedKey: String) -> Image {
        ImageCreator(url: url, uniqueKey: modifiedKey)
            .image
    }
}

extension BasicCharacterData {
    init?(character: MarvelCharacter) {
        self.init(
            id: character.id,
            name: character.name,
            description: character.description,
            thumbnail: character.thumbnail,
            modified: character.modified
        )
    }
}

extension BasicPublicationData {
    init?(publication: MarvelPublication) {
        self.init(
            id: publication.id,
            title: publication.title,
            thumbnail: publication.thumbnail,
            modified: publication.modified
        )
    }
}
