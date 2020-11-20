//
//  Image.swift
//  ImageLoader
//
//  Created by Hugo Alonso on 20/11/2020.
//

import Foundation

#if os(macOS)
import AppKit
public typealias UniversalImageView = NSImageView
#elseif !os(watchOS)
import UIKit
public typealias UniversalImageView = UIImageView
#endif

public typealias ImageLoadCompleted = (Error?) -> Void

public protocol Image {
    func prefetch(completion: @escaping ImageLoadCompleted)
    func render(on imageView: UniversalImageView, completion: @escaping ImageLoadCompleted)
}

public extension Image {
    func prefetch() {
        prefetch(completion: { _ in })
    }

    func render(on imageView: UniversalImageView) {
        render(on: imageView, completion: { _ in })
    }
}
