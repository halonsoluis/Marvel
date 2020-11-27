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

class MainComposer {

    private var itemProvider: MarvelFeedProvider {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let charactersLoader = MarvelCharactersFeedLoader(client: client)

        let prefetchImageHandler = { (url: URL, modifiedKey: String) in
            ImageLoader(url: url, uniqueKey: modifiedKey).image.prefetch(completion: { _ in })
        }

        let loadImageHandler = { (url: URL, modifiedKey: String, imageView: UIImageView) in
            ImageLoader(url: url, uniqueKey: modifiedKey).image.render(on: imageView, completion: { _ in })
        }

        return MarvelFeedProvider(charactersLoader: charactersLoader, prefetchImageHandler: prefetchImageHandler, loadImageHandler: loadImageHandler)
    }

    var feedView: FeedViewController {
        FeedViewController(feedDataProvider: itemProvider)
    }
}
