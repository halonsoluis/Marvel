//
//  ImageCreator.swift
//  ImageLoader
//
//  Created by Hugo Alonso on 20/11/2020.
//

import Foundation

public struct ImageLoader {

    let url: URL
    let uniqueKey: String

    public init(url: URL, uniqueKey: String) {
        self.url = url
        self.uniqueKey = uniqueKey
    }

    public var image: Image {
        CachedImage(url: url, uniqueKey: uniqueKey)
    }
}

