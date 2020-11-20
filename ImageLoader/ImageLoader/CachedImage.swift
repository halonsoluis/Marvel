//
//  CachedImage.swift
//  ImageLoader
//
//  Created by Hugo Alonso on 20/11/2020.
//

import Foundation
import Kingfisher

struct CachedImage: Image {
    let url: URL
    let uniqueKey: String

    private var resourceKey: String { "\(url.absoluteString)-\(uniqueKey)" }
    private var resource: ImageResource { ImageResource(downloadURL: url, cacheKey: resourceKey) }

    func prefetch(completion: @escaping ImageLoadCompleted) {
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case let .failure(error):
                completion(error)
            default:
                completion(nil)
            }
        }
    }

    func render(on imageView: UniversalImageView, completion: @escaping ImageLoadCompleted) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: resource, options: [.transition(transition)], completionHandler:  { result in
            switch result {
            case let .failure(error):
                completion(error)
            default:
                completion(nil)
            }
        })
    }

    private var transition: ImageTransition {
        #if os(iOS) || os(tvOS)
        return .fade(1)
        #else
        return .none
        #endif
    }
}
