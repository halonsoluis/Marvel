import CharactersAPI
import Foundation
import ImageLoader
import UIKit

typealias ImageFormula = (url: URL, uniqueKey: String)
typealias Router = (_ route: Route) -> Void
typealias PrefetchImageHandler = (ImageFormula) -> Cancellable?
typealias LoadImageHandler = (ImageFormula, _ destinationView: UIImageView) -> Cancellable?

enum Route: Equatable {
    case details(for: MarvelCharacter)
}

final class MainComposer {
    private var createSectionsForCharacter: ((BasicCharacterData) -> Void)?

    func compose(using window: UIWindow) {
        let marvelFeed = MarvelCharactersFeedLoader(
            client: URLSessionHTTPClient(session: URLSession.shared)
        )

        let feedUseCase = CharactersFeedUseCaseComposer(
            marvelFeed: marvelFeed,
            router: router
        )

        let detailsUseCase = CharactersDetailsUseCaseComposer(
            marvelFeed: marvelFeed
        )

        let mainView = MainSplitView(
            mainViewVC: feedUseCase.composeFeedListController()
        )

        createSectionsForCharacter = { (character: BasicCharacterData) in
            mainView.show(
                detailsUseCase.createDetails(for: character)
            )
        }

        mainView.injectAsRoot(in: window)
    }

    static func bind(controller: AnyObject & ContentUpdatable, feed: ContentUpdatePerformer) {
        var feed = feed
        feed.onItemsChangeCallback = { [weak controller] in
            controller?.update()
        }
    }

    // MARK: - Navigation

    private func router(route: Route) {
        switch route {
        case let .details(for: item):
            guard let character = BasicCharacterData(character: item) else {
                return
            }

            DispatchQueue.main.async {
                self.createSectionsForCharacter?(character)
            }
        }
    }

    // MARK: - Image Handling

    static func prefetchImageHandler(url: URL, modifiedKey: String) -> Cancellable? {
        ImageCreator(url: url, uniqueKey: modifiedKey)
            .image
            .prefetch(completion: { _ in })
    }

    static func loadImageHandler(imageFormula: ImageFormula, imageView: UIImageView) -> Cancellable? {
        ImageCreator(url: imageFormula.url, uniqueKey: imageFormula.uniqueKey)
            .image
            .render(on: imageView, completion: { _ in })
    }
}
