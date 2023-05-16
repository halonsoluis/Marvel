import Foundation

#if os(macOS)
    import AppKit
    public typealias UniversalImageView = NSImageView
#elseif !os(watchOS)
    import UIKit
    public typealias UniversalImageView = UIImageView
#endif

public typealias ImageLoadCompleted = (Error?) -> Void

public protocol Cancellable {
    func cancel()
}

public protocol Image {
    func prefetch(completion: @escaping ImageLoadCompleted) -> Cancellable?
    func render(on imageView: UniversalImageView, completion: @escaping ImageLoadCompleted) -> Cancellable?
}
